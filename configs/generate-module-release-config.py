#!/usr/bin/env python3
"""Generate release-automation monorepo config for all terraform module folders.

Emits:
  module-release-config.json      one package entry per terraform-* folder
  .module-versions.json           seeded with each module's current version

Version source order: submodule git tag -> CHANGELOG.md latest entry -> 0.0.0.
Re-runnable: regenerates both files from the current tree state. Run from the
repository root:

    python3 configs/generate-module-release-config.py
"""

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CHANGELOG_VERSION_RE = re.compile(r"^## \[v?(\d+\.\d+\.\d+)\]", re.MULTILINE)


def module_dirs() -> list[str]:
    return sorted(
        p.name
        for p in ROOT.iterdir()
        if p.is_dir() and p.name.startswith("terraform-")
    )


def version_from_git(module: str) -> str | None:
    try:
        out = subprocess.run(
            ["git", "-C", str(ROOT / module), "describe", "--tags", "--abbrev=0"],
            capture_output=True, text=True, timeout=30,
        )
    except subprocess.TimeoutExpired:
        return None
    if out.returncode != 0:
        return None
    tag = out.stdout.strip().lstrip("v")
    return tag if re.fullmatch(r"\d+\.\d+\.\d+", tag) else None


def version_from_changelog(module: str) -> str | None:
    changelog = ROOT / module / "CHANGELOG.md"
    if not changelog.is_file():
        return None
    match = CHANGELOG_VERSION_RE.search(changelog.read_text(errors="replace"))
    return match.group(1) if match else None


def main() -> int:
    modules = module_dirs()
    if not modules:
        print("no terraform-* module folders found", file=sys.stderr)
        return 1

    manifest: dict[str, str] = {}
    packages: dict[str, dict] = {}
    fallbacks: list[str] = []

    for module in modules:
        version = version_from_git(module) or version_from_changelog(module)
        if version is None:
            version = "0.0.0"
            fallbacks.append(module)
        manifest[module] = version
        packages[module] = {"component": module}

    config = {
        "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
        "release-type": "terraform-module",
        "tag-separator": "/",
        "include-component-in-tag": True,
        "include-v-in-tag": True,
        "bump-minor-pre-major": True,
        "separate-pull-requests": True,
        "packages": packages,
    }

    (ROOT / "module-release-config.json").write_text(
        json.dumps(config, indent=2) + "\n"
    )
    (ROOT / ".module-versions.json").write_text(
        json.dumps(manifest, indent=2) + "\n"
    )

    print(f"generated config for {len(modules)} modules")
    if fallbacks:
        print(f"WARNING {len(fallbacks)} modules fell back to 0.0.0: {', '.join(fallbacks)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
