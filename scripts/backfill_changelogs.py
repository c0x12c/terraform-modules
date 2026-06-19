#!/usr/bin/env python3
"""Backfill per-version changelog sections into the registry R2 bucket."""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

import boto3

from changelog import split_changelog

NAMESPACE = "c0x12c"


def registry_key(module: str, namespace: str = NAMESPACE) -> str:
    parts = module.split("-")
    return "%s/%s/%s" % (namespace, "-".join(parts[2:]), parts[1])


def list_module_dirs() -> list[str]:
    return sorted(
        path.name
        for path in Path(".").iterdir()
        if path.is_dir() and path.name.startswith("terraform-")
    )


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--bucket", default=os.environ.get("REGISTRY_BUCKET"))
    parser.add_argument("--org", default="c0x12c")
    parser.add_argument(
        "--modules",
        nargs="*",
        help="module dir names; default = all terraform-* dirs",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    modules = args.modules or list_module_dirs()
    client = boto3.client("s3", endpoint_url=os.environ["R2_ENDPOINT"])

    for module in modules:
        module_dir = Path(module)
        changelog_path = module_dir / "CHANGELOG.md"
        if not changelog_path.is_file():
            print("skip %s (no CHANGELOG.md)" % module, file=sys.stderr)
            continue

        sections = split_changelog(changelog_path.read_text(encoding="utf-8"))
        key = registry_key(module, args.org)
        for version, section in sections.items():
            client.put_object(
                Bucket=args.bucket,
                Key="modules/%s/%s.changelog.md" % (key, version),
                Body=section.encode("utf-8"),
                ContentType="text/markdown",
            )
        print("backfilled %-44s %d changelog sections" % (module, len(sections)))

    return 0


if __name__ == "__main__":
    sys.exit(main())
