#!/usr/bin/env python3
"""Prototype: backfill ALL historical module versions into the registry R2
bucket, so the self-hosted registry is a complete superset before any consumer
cuts over (the swift-migration enabler).

Each mirror repo holds the full semver tag history. For every tag we
`git archive` the tree (files at archive ROOT — matches worker.js) and upload
the tarball, then write a single index.json. Idempotent: re-running re-uploads
the same content.

    R2_ENDPOINT=https://<acct>.r2.cloudflarestorage.com \
    AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... \
    python3 backfill.py --org c0x12c --bucket c0x12c-tf-modules \
        --modules terraform-aws-rds terraform-aws-vpc   # omit to read every terraform-* dir

Derives the mirror repo from the module dir name: <org>/<module>.
"""
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import boto3  # pip install boto3

NAMESPACE = "c0x12c"
SEMVER_TAG = re.compile(r"^v?(\d+)\.(\d+)\.(\d+)$")


def registry_key(module: str) -> str:
    p = module.split("-")
    return "%s/%s/%s" % (NAMESPACE, "-".join(p[2:]), p[1])


def list_module_dirs() -> list:
    return sorted(p.name for p in Path(".").iterdir()
                  if p.is_dir() and p.name.startswith("terraform-"))


def semver_tags(repo_url: str) -> list:
    out = subprocess.run(["git", "ls-remote", "--tags", repo_url],
                         capture_output=True, text=True, check=True).stdout
    tags = []
    for line in out.splitlines():
        ref = line.split("\t")[-1].replace("refs/tags/", "").replace("^{}", "")
        if SEMVER_TAG.match(ref):
            tags.append(ref)
    return sorted(set(tags), key=lambda t: tuple(int(x) for x in SEMVER_TAG.match(t).groups()))


def archive_tag(clone_dir: str, tag: str) -> bytes:
    # git archive of a tag = repo files at archive root (no wrapper dir).
    return subprocess.run(["git", "-C", clone_dir, "archive", "--format=tar.gz", tag],
                          capture_output=True, check=True).stdout


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--org", default="c0x12c")
    ap.add_argument("--bucket", default=os.environ.get("REGISTRY_BUCKET"))
    ap.add_argument("--modules", nargs="*", help="module dir names; default = all terraform-* dirs")
    args = ap.parse_args()

    modules = args.modules or list_module_dirs()
    s3 = boto3.client("s3", endpoint_url=os.environ["R2_ENDPOINT"])

    # Merge into the existing index, never overwrite: a partial run
    # (--modules <subset>) must not drop other modules' entries.
    try:
        index = json.loads(s3.get_object(Bucket=args.bucket, Key="index.json")["Body"].read())
    except s3.exceptions.NoSuchKey:
        index = {}

    for module in modules:
        repo_url = "https://github.com/%s/%s.git" % (args.org, module)
        try:
            tags = semver_tags(repo_url)
        except subprocess.CalledProcessError:
            print("skip %s (no mirror repo / unreachable)" % module, file=sys.stderr)
            continue
        if not tags:
            print("skip %s (no semver tags)" % module, file=sys.stderr)
            continue

        key = registry_key(module)
        with tempfile.TemporaryDirectory() as tmp:
            subprocess.run(["git", "clone", "--bare", "--quiet", repo_url, tmp], check=True)
            for tag in tags:
                ver = tag.lstrip("v")
                s3.put_object(Bucket=args.bucket,
                              Key="modules/%s/%s.tar.gz" % (key, ver),
                              Body=archive_tag(tmp, tag),
                              ContentType="application/gzip")
            merged = set(index.get(key, [])) | {t.lstrip("v") for t in tags}
            index[key] = sorted(merged, key=lambda v: tuple(int(x) for x in v.split(".")))
        print("backfilled %-44s %d versions" % (module, len(tags)))

    s3.put_object(Bucket=args.bucket, Key="index.json",
                  Body=(json.dumps(index, indent=2, sort_keys=True) + "\n").encode(),
                  ContentType="application/json")
    print("index.json written: %d modules" % len(index))
    return 0


if __name__ == "__main__":
    sys.exit(main())
