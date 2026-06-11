#!/usr/bin/env python3
"""Prototype: pack a released module into a tarball and upload to the registry
R2 bucket, updating index.json. R2 is S3-compatible (boto3).

Run per released module in the release pipeline (same inputs the cascade job
already has: module dir + version). Module files are packed at the archive
ROOT so the worker's X-Terraform-Get needs no //subdir.

    R2_ENDPOINT=https://<acct>.r2.cloudflarestorage.com \
    AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... \
    python3 publish_registry.py --module terraform-aws-rds --version v0.6.6 --bucket c0x12c-tf-modules
"""
import argparse
import io
import json
import os
import sys
import tarfile

import boto3  # pip install boto3

NAMESPACE = "c0x12c"
EXCLUDE_DIRS = {".git", ".terraform", "examples", "test", "tests"}


def registry_key(module: str) -> str:
    # terraform-<provider>-<name...> -> <ns>/<name>/<provider>
    p = module.split("-")
    return "%s/%s/%s" % (NAMESPACE, "-".join(p[2:]), p[1])


def pack(module_dir: str) -> bytes:
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode="w:gz") as tar:
        for root, dirs, files in os.walk(module_dir):
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
            for f in files:
                full = os.path.join(root, f)
                tar.add(full, arcname=os.path.relpath(full, module_dir))
    return buf.getvalue()


def semver_key(v: str):
    return tuple(int(x) for x in v.split("."))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--module", required=True)
    ap.add_argument("--version", required=True, help="vX.Y.Z")
    ap.add_argument("--bucket", default=os.environ.get("REGISTRY_BUCKET"))
    args = ap.parse_args()

    ver = args.version.lstrip("v")
    key = registry_key(args.module)
    s3 = boto3.client("s3", endpoint_url=os.environ["R2_ENDPOINT"])

    s3.put_object(
        Bucket=args.bucket,
        Key="modules/%s/%s.tar.gz" % (key, ver),
        Body=pack(args.module),
        ContentType="application/gzip",
    )

    try:
        idx = json.loads(s3.get_object(Bucket=args.bucket, Key="index.json")["Body"].read())
    except s3.exceptions.NoSuchKey:
        idx = {}
    versions = set(idx.get(key, [])) | {ver}
    idx[key] = sorted(versions, key=semver_key)
    s3.put_object(
        Bucket=args.bucket,
        Key="index.json",
        Body=(json.dumps(idx, indent=2) + "\n").encode(),
        ContentType="application/json",
    )
    print("published %s %s -> %s" % (args.module, ver, key))
    return 0


if __name__ == "__main__":
    sys.exit(main())
