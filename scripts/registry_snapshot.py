"""Offsite snapshot and restore for the registry R2 bucket.

Covers OBJECT loss - an accidental delete, a bad script, a corrupted upload. It
does NOT cover Cloudflare account loss: the zone and the Worker go with the
account, and a copy of the bucket does not bring DNS back. Restored objects are
only useful once there is somewhere to restore them to.

Snapshot and restore live in one file on purpose. The reader of the format must
not be able to rot separately from its writer.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

import boto3

INDEX_KEY = "index.json"

CONTENT_TYPES = {
    ".json": "application/json",
    ".gz": "application/gzip",
}


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def content_type_for(key: str) -> str:
    return CONTENT_TYPES.get(Path(key).suffix, "application/octet-stream")


def iter_objects(client, bucket):
    """Yield every object summary, following continuation tokens.

    Written as an explicit loop rather than a paginator so the pagination path
    is reachable from a plain fake in tests - it is the branch most likely to be
    silently wrong, because a bucket only grows past one page over time.
    """
    token = None
    while True:
        kwargs = {"Bucket": bucket}
        if token:
            kwargs["ContinuationToken"] = token
        page = client.list_objects_v2(**kwargs)
        for item in page.get("Contents") or []:
            yield item
        if not page.get("IsTruncated"):
            return
        token = page.get("NextContinuationToken")
        if not token:
            return


def missing_index_coverage(index, keys):
    """Modules listed in index.json with no tarball present in the bucket.

    An index entry with no object behind it is what a half-finished publish
    leaves, and a snapshot that captures it would let a restore reproduce the
    broken state faithfully.
    """
    missing = []
    for module_key, versions in index.items():
        if not any("modules/%s/%s.tar.gz" % (module_key, v) in keys for v in versions or []):
            missing.append(module_key)
    return sorted(missing)


def snapshot(client, bucket, out_dir, now=None):
    out = Path(out_dir)
    objects_dir = out / "objects"
    payloads = {}

    for item in iter_objects(client, bucket):
        key = item["Key"]
        body = client.get_object(Bucket=bucket, Key=key)["Body"].read()
        payloads[key] = body

    if not payloads:
        raise SystemExit("refusing to write an empty snapshot: bucket listed no objects")

    if INDEX_KEY not in payloads:
        raise SystemExit("refusing to write a snapshot with no %s" % INDEX_KEY)

    try:
        index = json.loads(payloads[INDEX_KEY].decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise SystemExit("%s does not parse as JSON: %s" % (INDEX_KEY, exc))

    if not isinstance(index, dict):
        raise SystemExit("%s is not a JSON object" % INDEX_KEY)

    missing = missing_index_coverage(index, set(payloads))
    if missing:
        raise SystemExit(
            "index.json lists %d module(s) with no tarball in the bucket: %s"
            % (len(missing), ", ".join(missing[:5]))
        )

    manifest_objects = {}
    for key, body in sorted(payloads.items()):
        target = objects_dir / key
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(body)
        manifest_objects[key] = {"size": len(body), "sha256": sha256_hex(body)}

    generated = now or datetime.now(timezone.utc).isoformat()
    manifest = {
        "generated_at": generated,
        "bucket": bucket,
        "object_count": len(payloads),
        "total_bytes": sum(len(b) for b in payloads.values()),
        "objects": manifest_objects,
    }
    out.mkdir(parents=True, exist_ok=True)
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    return manifest


def load_manifest(snapshot_dir):
    path = Path(snapshot_dir) / "manifest.json"
    if not path.exists():
        raise SystemExit("no manifest.json in %s - not a snapshot directory" % snapshot_dir)
    return json.loads(path.read_text(encoding="utf-8"))


def restore(client, bucket, snapshot_dir, apply=False):
    """Upload a snapshot back into a bucket.

    Dry run unless apply=True. A restore tool that writes by default is a
    footgun pointed at the live registry, so the safe mode is the default and
    the destructive one has to be asked for.
    """
    manifest = load_manifest(snapshot_dir)
    objects_dir = Path(snapshot_dir) / "objects"

    planned = []
    for key, meta in sorted(manifest["objects"].items()):
        path = objects_dir / key
        if not path.exists():
            raise SystemExit("snapshot is incomplete: %s missing from objects/" % key)
        body = path.read_bytes()
        actual = sha256_hex(body)
        if actual != meta["sha256"]:
            raise SystemExit(
                "checksum mismatch for %s: manifest %s, file %s" % (key, meta["sha256"], actual)
            )
        planned.append((key, body))

    if not apply:
        print("DRY RUN: would upload %d object(s) to %s" % (len(planned), bucket))
        print("re-run with --apply to write")
        return {"uploaded": 0, "planned": len(planned)}

    for key, body in planned:
        client.put_object(
            Bucket=bucket, Key=key, Body=body, ContentType=content_type_for(key)
        )
    print("uploaded %d object(s) to %s" % (len(planned), bucket))
    return {"uploaded": len(planned), "planned": len(planned)}


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    snap = sub.add_parser("snapshot", help="copy a bucket to a local directory")
    snap.add_argument("--bucket", required=True)
    snap.add_argument("--out", required=True)
    snap.add_argument("--now", help="ISO8601 timestamp to stamp instead of the clock")

    rest = sub.add_parser("restore", help="upload a snapshot directory to a bucket")
    rest.add_argument("--bucket", required=True)
    rest.add_argument("--from", dest="source", required=True)
    rest.add_argument("--apply", action="store_true", help="actually write; default is a dry run")

    args = parser.parse_args(argv)
    client = boto3.client("s3", endpoint_url=os.environ["R2_ENDPOINT"])

    if args.command == "snapshot":
        manifest = snapshot(client, args.bucket, args.out, now=args.now)
        print(
            "snapshot: %d objects, %d bytes -> %s"
            % (manifest["object_count"], manifest["total_bytes"], args.out)
        )
        return 0

    restore(client, args.bucket, args.source, apply=args.apply)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
