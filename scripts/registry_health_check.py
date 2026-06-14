#!/usr/bin/env python3

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path


DEFAULT_REGISTRY_BASE = "https://terraform.c0x12c.com"
DEFAULT_ORG = "c0x12c"
# Cloudflare in front of the registry 403s the default "Python-urllib/x" agent,
# so identify the probe explicitly.
USER_AGENT = "terraform-registry-health-check/1.0"
EXCEPTIONS = {
    "terraform-aws-opensearch": (
        "registry has orphan 0.4.0 from archived-mirror backfill; monorepo is at "
        "0.3.16 and registry lacks it - cutover reconciliation tracked under issue #1914"
    )
}


def module_key(module_dir, org):
    parts = module_dir.split("-")
    if len(parts) < 3 or parts[0] != "terraform":
        return None
    provider = parts[1]
    name = "-".join(parts[2:])
    if not provider or not name:
        return None
    return "%s/%s/%s" % (org, name, provider)


def check_coverage(manifest, index, org, exceptions):
    discrepancies = []
    for module, version in sorted(manifest.items()):
        if version == "0.0.0":
            continue
        key = module_key(module, org)
        if key is None:
            discrepancies.append(
                "coverage: %s %s (manifest) has invalid module name" % (module, version)
            )
            continue
        versions = list(index.get(key, []))
        if module in exceptions:
            if version in set(versions):
                discrepancies.append(
                    "exception no longer needed for %s (now passes) - remove it: %s"
                    % (module, exceptions[module])
                )
            continue
        if version not in set(versions):
            discrepancies.append(
                "coverage: %s %s (manifest) missing from index.json (%s has %s)"
                % (module, version, key, versions or None)
            )
    return discrepancies


def _request(url, retries=3, backoff=1.0, read_bytes=None):
    last_error = None
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    for attempt in range(retries):
        try:
            response = urllib.request.urlopen(request, timeout=30)
            try:
                status = getattr(response, "status", None)
                if status is None:
                    status = response.getcode()
                headers = getattr(response, "headers", {})
                body = b""
                if read_bytes is None:
                    body = response.read()
                else:
                    body = response.read(read_bytes)
                return status, headers, body
            finally:
                response.close()
        except urllib.error.HTTPError as exc:
            if exc.code >= 500 and attempt + 1 < retries:
                time.sleep(backoff * (2 ** attempt))
                continue
            return exc.code, exc.headers, b""
        except Exception as exc:
            retriable = False
            status = getattr(exc, "code", None)
            if isinstance(exc, TimeoutError):
                retriable = True
            elif isinstance(exc, urllib.error.URLError):
                retriable = True
            elif isinstance(status, int) and status >= 500:
                retriable = True
            if not retriable or attempt + 1 >= retries:
                raise
            last_error = exc
            time.sleep(backoff * (2 ** attempt))
    raise last_error


def _http(url, retries=3, backoff=1.0):
    status, headers, _ = _request(url, retries=retries, backoff=backoff)
    return status, headers


def check_resolvability(index, registry_base, retries, backoff):
    discrepancies = []
    base = registry_base.rstrip("/")
    for key in sorted(index):
        versions_url = "%s/v1/modules/%s/versions" % (base, key)
        try:
            status, _, body = _request(
                versions_url, retries=retries, backoff=backoff, read_bytes=None
            )
        except Exception as exc:
            discrepancies.append("resolve: %s /versions error=%s" % (key, exc))
            continue
        if status != 200:
            discrepancies.append("resolve: %s /versions returned %s" % (key, status))
            continue
        try:
            payload = json.loads(body.decode("utf-8"))
        except Exception:
            discrepancies.append("resolve: %s /versions returned invalid json" % key)
            continue
        modules = payload.get("modules") or []
        served_versions = set()
        if modules:
            served_versions = {
                item.get("version")
                for item in modules[0].get("versions", [])
                if item.get("version")
            }
        expected_versions = list(index.get(key, []))
        for version in expected_versions:
            if version not in served_versions:
                discrepancies.append(
                    "resolve: %s %s not served by /versions" % (key, version)
                )
        for version in expected_versions:
            download_url = "%s/v1/modules/%s/%s/download" % (base, key, version)
            try:
                status, headers = _http(download_url, retries=retries, backoff=backoff)
            except Exception as exc:
                discrepancies.append(
                    "resolve: %s %s download error=%s" % (key, version, exc)
                )
                continue
            archive_url = headers.get("X-Terraform-Get")
            if status != 204 or not archive_url:
                discrepancies.append(
                    "resolve: %s %s download status=%s x-terraform-get=%s"
                    % (key, version, status, bool(archive_url))
                )
                continue
            try:
                archive_status, _, _ = _request(
                    archive_url, retries=retries, backoff=backoff, read_bytes=1
                )
            except Exception as exc:
                discrepancies.append(
                    "resolve: %s %s archive error=%s" % (key, version, exc)
                )
                continue
            if archive_status != 200:
                discrepancies.append(
                    "resolve: %s %s archive status=%s" % (key, version, archive_status)
                )
    return discrepancies


def load_index(client, bucket):
    payload = client.get_object(Bucket=bucket, Key="index.json")
    return json.load(payload["Body"])


def load_manifest(path):
    with Path(path).open("r", encoding="utf-8") as handle:
        return json.load(handle)


def build_report(cov, res):
    total = len(cov) + len(res)
    if total == 0:
        return "\n".join(
            [
                "All registry health checks passed",
                "",
                "Coverage discrepancies: 0",
                "Resolvability discrepancies: 0",
            ]
        )
    lines = ["Registry health check found %d discrepancy(s)" % total, ""]
    lines.append("## Coverage")
    if cov:
        lines.extend("- %s" % item for item in cov)
    else:
        lines.append("- none")
    lines.append("")
    lines.append("## Resolvability")
    if res:
        lines.extend("- %s" % item for item in res)
    else:
        lines.append("- none")
    return "\n".join(lines)


def _write_report(report, report_file):
    if report_file == "-":
        print(report)
        return
    Path(report_file).write_text(report, encoding="utf-8")


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument("--r2-bucket", required=True)
    parser.add_argument("--manifest", default=".module-versions.json")
    parser.add_argument("--registry-base", default=DEFAULT_REGISTRY_BASE)
    parser.add_argument("--org", default=DEFAULT_ORG)
    parser.add_argument("--report-file", default="-")
    parser.add_argument("--skip-resolve", action="store_true")
    parser.add_argument("--retries", type=int, default=3)
    parser.add_argument("--backoff", type=float, default=1.0)
    args = parser.parse_args(argv)

    import boto3

    client = boto3.client("s3", endpoint_url=os.environ["R2_ENDPOINT"])
    index = load_index(client, args.r2_bucket)
    manifest = load_manifest(args.manifest)
    coverage = check_coverage(manifest, index, args.org, EXCEPTIONS)
    resolvability = []
    if not args.skip_resolve:
        resolvability = check_resolvability(
            index,
            args.registry_base,
            retries=args.retries,
            backoff=args.backoff,
        )
    report = build_report(coverage, resolvability)
    _write_report(report, args.report_file)
    total = len(coverage) + len(resolvability)
    print(
        "registry health check: coverage=%d resolvability=%d total=%d"
        % (len(coverage), len(resolvability), total)
    )
    return 1 if total else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
