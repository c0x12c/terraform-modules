#!/usr/bin/env python3
"""Generate the AWS service quota catalog for one region, one CSV per service.

Lists every service with ListServices, then every default quota of each service with
ListAWSDefaultServiceQuotas. Rows are sorted by quota_name. Default quotas do not depend
on the account, so any read-only profile works.

    python3 scripts/generate_service_quota_catalog.py \
        --output-dir docs/service-quotas/us-west-2

    # Live search, always current: one CSV with every service goes to stdout, logs to stderr.
    python3 scripts/generate_service_quota_catalog.py --output - | grep -i "fargate"

One file per service keeps each CSV small enough for GitHub to render as a table and to
index for code search. With --output-dir the script writes <service_code>.csv, deletes the
CSV of any service AWS no longer lists, and rewrites the generator-owned blocks of the
README (default: README.md in the parent of the output directory): the catalog-metadata
block (date, region, counts, source APIs) and the catalog-index block (one row per service).

Exit 0 on success; 1 when the README markers are missing or any service failed. Failed
services are logged and skipped; the directory and README are then left untouched so a
partial catalog is never committed, while stdout mode still prints the rows it could list.
Requires boto3 (scripts/requirements.txt); it is imported only when the script calls AWS.
"""
import argparse
import csv
import datetime
import io
import os
import re
import sys
from pathlib import Path

COLUMNS = [
    "service_code",
    "service_name",
    "quota_code",
    "quota_name",
    "description",
    "default_value",
    "unit",
    "adjustable",
    "global_quota",
]
BLOCKS = ("catalog-metadata", "catalog-index")
SOURCE_APIS = "ListServices, ListAWSDefaultServiceQuotas"
SERVICE_CODE_RE = re.compile(r"^[A-Za-z0-9-]+$")
PAGE_SIZE = 100


def log(message: str) -> None:
    print(message, file=sys.stderr)


def block_pattern(name: str) -> re.Pattern:
    return re.compile(rf"<!-- BEGIN {name} -->.*?<!-- END {name} -->", re.DOTALL)


def paginate(call, result_key: str, **kwargs) -> list:
    items = []
    token = None
    while True:
        page_kwargs = dict(kwargs, MaxResults=PAGE_SIZE)
        if token:
            page_kwargs["NextToken"] = token
        response = call(**page_kwargs)
        items.extend(response.get(result_key, []))
        token = response.get("NextToken")
        if not token:
            return items


def format_number(value) -> str:
    if value is None:
        return ""
    number = float(value)
    return str(int(number)) if number.is_integer() else repr(number)


def to_row(service: dict, quota: dict) -> dict:
    return {
        "service_code": quota.get("ServiceCode") or service["ServiceCode"],
        "service_name": quota.get("ServiceName") or service.get("ServiceName", ""),
        "quota_code": quota["QuotaCode"],
        "quota_name": quota.get("QuotaName", ""),
        "description": quota.get("Description", ""),
        "default_value": format_number(quota.get("Value")),
        "unit": quota.get("Unit", ""),
        "adjustable": str(bool(quota.get("Adjustable", False))).lower(),
        "global_quota": str(bool(quota.get("GlobalQuota", False))).lower(),
    }


def collect(client) -> tuple:
    """Return ({service_code: (service_name, rows sorted by quota_name)}, failed codes)."""
    catalog = {}
    failed = []
    for service in paginate(client.list_services, "Services"):
        code = service["ServiceCode"]
        if not SERVICE_CODE_RE.match(code):
            log(f"skipped service {code!r}: not usable as a file name")
            failed.append(code)
            continue
        try:
            quotas = paginate(client.list_aws_default_service_quotas, "Quotas", ServiceCode=code)
        except Exception as error:  # one broken service must not hide the others
            log(f"skipped service {code}: {error}")
            failed.append(code)
            continue
        rows = sorted((to_row(service, quota) for quota in quotas),
                      key=lambda row: (row["quota_name"].lower(), row["quota_code"]))
        catalog[code] = (service.get("ServiceName", ""), rows)
    return dict(sorted(catalog.items())), failed


def render_csv(rows: list) -> str:
    buffer = io.StringIO()
    writer = csv.DictWriter(buffer, fieldnames=COLUMNS, lineterminator="\n")
    writer.writeheader()
    writer.writerows(rows)
    return buffer.getvalue()


def render_metadata(region: str, catalog: dict, today: datetime.date) -> str:
    quota_count = sum(len(rows) for _, rows in catalog.values())
    return "\n".join([
        "<!-- BEGIN catalog-metadata -->",
        f"- Generated: {today.isoformat()} (UTC) by `scripts/generate_service_quota_catalog.py`",
        f"- Region: `{region}`",
        f"- Services: {len(catalog)}; quotas: {quota_count}",
        f"- Source APIs: {SOURCE_APIS}",
        "<!-- END catalog-metadata -->",
    ])


def render_index(catalog: dict, link_prefix: str) -> str:
    lines = [
        "<!-- BEGIN catalog-index -->",
        "| service_code | Service | Quotas |",
        "|---|---|---:|",
    ]
    for code, (name, rows) in catalog.items():
        safe_name = name.replace("|", "\\|")
        lines.append(f"| [`{code}`]({link_prefix}{code}.csv) | {safe_name} | {len(rows)} |")
    lines.append("<!-- END catalog-index -->")
    return "\n".join(lines)


def missing_blocks(readme: Path) -> list:
    text = readme.read_text(encoding="utf-8") if readme.exists() else ""
    return [name for name in BLOCKS if not block_pattern(name).search(text)]


def replace_block(text: str, name: str, content: str) -> str:
    return block_pattern(name).sub(lambda _: content, text, count=1)


def write_catalog(output_dir: Path, readme: Path, region: str, catalog: dict, today: datetime.date) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    for stale in output_dir.glob("*.csv"):
        if stale.stem not in catalog:
            stale.unlink()
            log(f"removed {stale.name}: service no longer listed")
    for code, (_, rows) in catalog.items():
        (output_dir / f"{code}.csv").write_text(render_csv(rows), encoding="utf-8")

    link_prefix = Path(os.path.relpath(output_dir, readme.parent)).as_posix() + "/"
    text = readme.read_text(encoding="utf-8")
    text = replace_block(text, "catalog-metadata", render_metadata(region, catalog, today))
    text = replace_block(text, "catalog-index", render_index(catalog, link_prefix))
    readme.write_text(text, encoding="utf-8")


def make_client(region: str):
    import boto3

    return boto3.client("service-quotas", region_name=region)


def main(argv=None, client=None, today=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--region", default="us-west-2", help="AWS region to list (default: us-west-2)")
    target = parser.add_mutually_exclusive_group(required=True)
    target.add_argument("--output-dir", type=Path, help="directory for one <service_code>.csv per service")
    target.add_argument("--output", choices=["-"], help="- writes one CSV with every service to stdout")
    parser.add_argument("--readme", type=Path,
                        help="README with the generator-owned blocks (default: <output-dir>/../README.md)")
    args = parser.parse_args(argv)

    readme = None
    if args.output_dir is not None:
        readme = args.readme or args.output_dir.parent / "README.md"
        # Check the markers before calling AWS so a missing block fails fast.
        missing = missing_blocks(readme)
        if missing:
            markers = ", ".join(f"<!-- BEGIN {n} --> ... <!-- END {n} -->" for n in missing)
            log(f"error: {readme} must contain {markers}")
            return 1

    catalog, failed = collect(client or make_client(args.region))
    if failed:
        log(f"error: {len(failed)} service(s) failed: {', '.join(failed)}")

    if readme is None:
        # Partial results still help a live search; the exit code reports the failure.
        sys.stdout.write(render_csv([row for _, rows in catalog.values() for row in rows]))
    elif failed:
        log(f"not writing {args.output_dir}: the catalog would be partial")
    else:
        today = today or datetime.datetime.now(datetime.timezone.utc).date()
        write_catalog(args.output_dir, readme, args.region, catalog, today)
        quota_count = sum(len(rows) for _, rows in catalog.values())
        log(f"wrote {quota_count} quotas from {len(catalog)} services to {args.output_dir}")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
