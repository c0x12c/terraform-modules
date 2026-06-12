#!/usr/bin/env python3
"""Fail if the module list drifts across its three hand-synced sources.

A module must appear in all three or none:
  1. on-disk `terraform-*` directories (the actual modules)
  2. `module-release-config.json` -> `packages` keys (release automation config)
  3. `.module-versions.json` keys (release automation manifest)

Adding / renaming / removing a module requires editing all three; this guard
turns a silent drift (a module that releases but isn't checked, or vice versa)
into a red PR.

    python3 scripts/check_module_drift.py [--repo-root <path>]

Exit 0 when the three sets are identical, 1 otherwise (printing the diff).
Stdlib only — safe to run in the CI detect job with no pip install.
"""
import argparse
import json
import sys
from pathlib import Path

CONFIG_FILE = "module-release-config.json"
VERSIONS_FILE = ".module-versions.json"
MODULE_PREFIX = "terraform-"


def disk_modules(root: Path) -> set:
    return {p.name for p in root.iterdir()
            if p.is_dir() and p.name.startswith(MODULE_PREFIX)}


def config_modules(root: Path) -> set:
    data = json.loads((root / CONFIG_FILE).read_text())
    return set(data.get("packages", {}).keys())


def versions_modules(root: Path) -> set:
    return set(json.loads((root / VERSIONS_FILE).read_text()).keys())


def _report(label: str, missing: set) -> None:
    for name in sorted(missing):
        print("  %-20s %s" % (label, name), file=sys.stderr)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo-root", default=".", type=Path)
    args = ap.parse_args()
    root = args.repo_root

    disk = disk_modules(root)
    config = config_modules(root)
    versions = versions_modules(root)

    if disk == config == versions:
        print("module lists in sync: %d modules across disk, %s, %s"
              % (len(disk), CONFIG_FILE, VERSIONS_FILE))
        return 0

    union = disk | config | versions
    print("module list DRIFT detected (a module must be in all three):",
          file=sys.stderr)
    _report("missing on disk:", union - disk)
    _report("missing in %s:" % CONFIG_FILE, union - config)
    _report("missing in %s:" % VERSIONS_FILE, union - versions)
    print("\ncounts: disk=%d config=%d versions=%d"
          % (len(disk), len(config), len(versions)), file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
