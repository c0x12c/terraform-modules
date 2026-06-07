#!/usr/bin/env python3
"""Cascade a leaf module release to its consuming parents.

Mirrors pin exact sibling versions from .module-versions.json at the parent's
release time, so a leaf fix reaches registry consumers only when each consuming
parent re-releases (see docs/decisions/2026-06-07-release-cascade.md). This
script finds direct parents of a released module and lands one
``fix(deps): bump <module> to <version> in <parent>`` commit per parent,
touching only the parent's ``.sibling-versions`` stamp file — enough for
release-please to open the parent's release PR.

Default is dry-run (prints planned bumps). Mutation requires --execute.
Transitive propagation is intentional-by-iteration: each parent's release
triggers its own cascade event.

    python3 scripts/cascade_release.py --module terraform-datadog-dashboard --version v1.2.3
    python3 scripts/cascade_release.py --module ... --version ... --execute
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

STAMP_FILENAME = ".sibling-versions"

# Same shape as mirror_release.SIBLING_SOURCE_RE: parent-escaping relative
# sibling source. Examples/test/tests dirs keep registry refs and never count.
PARENT_SOURCE_RE = re.compile(
    r'^\s*source\s*=\s*"\.\./(terraform-[A-Za-z0-9_-]+)"'
)

_EXEMPT_DIRS = {"examples", "test", "tests"}


class CascadeError(Exception):
    pass


def discover_parents(root: Path, module: str) -> list[str]:
    """Top-level terraform-* dirs with a non-exempt .tf referencing ../<module>."""
    parents = []
    for candidate in sorted(root.iterdir()):
        if not candidate.is_dir() or not candidate.name.startswith("terraform-"):
            continue
        if candidate.name == module:
            # A module cannot cascade into itself (cycle guard, level 0).
            continue
        if _references_module(candidate, module):
            parents.append(candidate.name)
    return parents


def _references_module(module_dir: Path, module: str) -> bool:
    for tf_file in module_dir.rglob("*.tf"):
        rel_parts = tf_file.relative_to(module_dir).parts
        if rel_parts and rel_parts[0] in _EXEMPT_DIRS:
            continue
        try:
            text = tf_file.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for line in text.splitlines():
            match = PARENT_SOURCE_RE.match(line)
            if match and match.group(1) == module:
                return True
    return False


def update_stamp(parent_dir: Path, module: str, version: str) -> bool:
    """Merge {module: version} into the parent's stamp. False if already recorded."""
    stamp_path = parent_dir / STAMP_FILENAME
    stamps = {}
    if stamp_path.is_file():
        try:
            stamps = json.loads(stamp_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise CascadeError(
                "corrupt stamp file %s: %s" % (stamp_path, exc)
            ) from exc
        if not isinstance(stamps, dict):
            raise CascadeError("stamp file %s must be a JSON object" % stamp_path)
    if stamps.get(module) == version:
        return False
    stamps[module] = version
    stamp_path.write_text(
        json.dumps(dict(sorted(stamps.items())), indent=2) + "\n", encoding="utf-8"
    )
    return True


def run_git(args, cwd, check=True):
    completed = subprocess.run(
        ["git"] + list(args), cwd=str(cwd), check=False, text=True,
        capture_output=True,
    )
    if check and completed.returncode != 0:
        raise CascadeError(
            "git %s failed: %s" % (" ".join(args), completed.stderr.strip())
        )
    return completed


def cascade(root: Path, module: str, version: str, execute: bool, push: bool = True) -> list[str]:
    """Returns the list of parents bumped (or that would be bumped)."""
    if not (root / module).is_dir():
        raise CascadeError("released module folder not found: %s" % module)
    if not re.fullmatch(r"v\d+\.\d+\.\d+", version):
        raise CascadeError("version must look like vX.Y.Z, got: %s" % version)

    parents = discover_parents(root, module)
    bumped = []
    for parent in parents:
        parent_dir = root / parent
        if not execute:
            stamp_path = parent_dir / STAMP_FILENAME
            already = False
            if stamp_path.is_file():
                try:
                    already = json.loads(stamp_path.read_text()).get(module) == version
                except (json.JSONDecodeError, AttributeError):
                    pass
            if already:
                print("skip %s: %s already at %s" % (parent, module, version))
                continue
            print("would bump %s: %s -> %s" % (parent, module, version))
            bumped.append(parent)
            continue

        if not update_stamp(parent_dir, module, version):
            print("skip %s: %s already at %s" % (parent, module, version))
            continue
        run_git(["add", str(parent_dir / STAMP_FILENAME)], cwd=root)
        run_git(
            ["commit", "-m", "fix(deps): bump %s to %s in %s" % (module, version, parent)],
            cwd=root,
        )
        print("bumped %s: %s -> %s" % (parent, module, version))
        bumped.append(parent)

    if execute and push and bumped:
        run_git(["push"], cwd=root)
    if not parents:
        print("no consuming parents for %s" % module)
    return bumped


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--module", required=True, help="released module folder name")
    parser.add_argument("--version", required=True, help="released version, vX.Y.Z")
    parser.add_argument("--root", default=".", help="monorepo root (default: cwd)")
    parser.add_argument(
        "--execute", action="store_true",
        help="commit and push stamp bumps (default: dry-run print only)",
    )
    args = parser.parse_args()
    try:
        cascade(Path(args.root).resolve(), args.module, args.version, args.execute)
    except CascadeError as exc:
        print("cascade error: %s" % exc, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
