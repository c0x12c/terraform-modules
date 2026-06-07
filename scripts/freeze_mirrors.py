#!/usr/bin/env python3
"""freeze_mirrors.py — remove .github/ from mirror repos so they become read-only outputs."""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


# ── Exit codes ──────────────────────────────────────────────────────────────
EXIT_GIT = 17
EXIT_IDENTITY = 14
EXIT_GENERAL = 1


# ── Error classes ────────────────────────────────────────────────────────────
class FreezeError(Exception):
    exit_code = EXIT_GENERAL
    failure_class = "freeze"


class IdentityError(FreezeError):
    exit_code = EXIT_IDENTITY
    failure_class = "identity"


class GitError(FreezeError):
    exit_code = EXIT_GIT
    failure_class = "git"


# ── Git helper ───────────────────────────────────────────────────────────────
def _redact(text: str) -> str:
    """Strip credentials from URLs (https://user:token@host -> https://***@host)."""
    return re.sub(r"(https?://)[^@/\s]+@", r"\1***@", text)


def run_git(args, cwd=None, check=True, capture_output=True):
    completed = subprocess.run(
        ["git"] + list(args),
        cwd=str(cwd) if cwd else None,
        check=False,
        text=True,
        capture_output=capture_output,
    )
    if check and completed.returncode != 0:
        raise GitError(
            "git: command failed (%s): %s"
            % (
                _redact(" ".join(["git"] + list(args))),
                _redact(completed.stderr.strip()),
            )
        )
    return completed


# ── Identity assert ──────────────────────────────────────────────────────────
def assert_mirror_identity(clone_dir: Path, module: str) -> None:
    remote_url = run_git(["remote", "get-url", "origin"], cwd=clone_dir).stdout.strip()
    normalized = remote_url.rstrip("/")
    if not (
        normalized.endswith("/%s" % module) or normalized.endswith("/%s.git" % module)
    ):
        raise IdentityError(
            "identity: remote %s does not match expected module %s"
            % (_redact(remote_url), module)
        )


# ── Git identity (commit attribution) ────────────────────────────────────────
def ensure_git_identity(repo: Path) -> None:
    run_git(["config", "user.name", "monorepo-freeze"], cwd=repo)
    run_git(["config", "user.email", "monorepo-freeze@example.invalid"], cwd=repo)


# ── Clone helper ─────────────────────────────────────────────────────────────
def clone_shallow(remote: str, destination: Path) -> None:
    """Shallow clone master; fall back to full clone when --depth is not supported."""
    result = run_git(
        ["clone", "--depth=1", "--branch", "master", remote, str(destination)],
        check=False,
    )
    if result.returncode != 0:
        # bare repos created by tests may not support --depth; try full clone
        run_git(["clone", "--branch", "master", remote, str(destination)])


# ── Compute removals ──────────────────────────────────────────────────────────
def compute_removals(clone_dir: Path) -> list:
    """Return list of paths (relative to clone_dir) that would be removed."""
    github_dir = clone_dir / ".github"
    if not github_dir.exists():
        return []
    removals = []
    for path in sorted(github_dir.rglob("*")):
        if path.is_file():
            removals.append(path.relative_to(clone_dir).as_posix())
    # Also include the directory entry itself so the caller knows the dir was present
    if removals or github_dir.is_dir():
        removals = [".github"] + removals
    return removals


# ── Apply removals ────────────────────────────────────────────────────────────
def apply_removals(clone_dir: Path) -> None:
    github_dir = clone_dir / ".github"
    if github_dir.exists():
        shutil.rmtree(github_dir)


# ── Default remote URL ────────────────────────────────────────────────────────
def default_remote(org: str, module: str) -> str:
    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        raise FreezeError("freeze: GITHUB_TOKEN is required to build the default remote")
    return "https://x-access-token:%s@github.com/%s/%s.git" % (token, org, module)


# ── Discover terraform-* modules ──────────────────────────────────────────────
def discover_modules(monorepo_root: Path) -> list:
    modules = sorted(
        d.name
        for d in monorepo_root.iterdir()
        if d.is_dir() and d.name.startswith("terraform-")
    )
    return modules


# ── Freeze a single module ────────────────────────────────────────────────────
FREEZE_COMMIT_MSG = (
    "chore: freeze mirror - this repo is a generated output of the "
    "terraform-modules-registry monorepo"
)


def freeze_module(module: str, remote: str, dry_run: bool) -> dict:
    """
    Returns a result dict:
      {"module": str, "status": "frozen"|"already-frozen"|"dry-run"|"FAILED <reason>",
       "removals": [...]}
    """
    with tempfile.TemporaryDirectory(prefix="freeze-mirror-") as tmp:
        clone_dir = Path(tmp) / "clone"
        try:
            clone_shallow(remote, clone_dir)
            assert_mirror_identity(clone_dir, module)
            removals = compute_removals(clone_dir)

            if not removals:
                return {"module": module, "status": "already-frozen", "removals": []}

            if dry_run:
                return {"module": module, "status": "dry-run", "removals": removals}

            apply_removals(clone_dir)
            ensure_git_identity(clone_dir)
            run_git(["add", "-A"], cwd=clone_dir)
            run_git(["commit", "-m", FREEZE_COMMIT_MSG], cwd=clone_dir)
            run_git(["push", "origin", "master"], cwd=clone_dir)
            return {"module": module, "status": "frozen", "removals": removals}

        except FreezeError as exc:
            return {
                "module": module,
                "status": "FAILED %s" % str(exc),
                "removals": [],
            }


# ── CLI ───────────────────────────────────────────────────────────────────────
def parse_args(argv):
    parser = argparse.ArgumentParser(
        description="Freeze terraform mirror repos to automation-only outputs."
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--modules", help="Comma-separated list of module names")
    group.add_argument(
        "--all",
        action="store_true",
        help="Freeze every terraform-* directory in repo root",
    )
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--org", default="c0x12c")
    parser.add_argument("--remote-base", help="Override remote URL prefix")
    parser.add_argument("--report", default=".agent/freeze-report.json")
    parser.add_argument("--monorepo-root", default=os.getcwd())
    return parser.parse_args(argv)


def main(argv=None) -> int:
    args = parse_args(argv or sys.argv[1:])
    monorepo_root = Path(args.monorepo_root).resolve()

    if args.all:
        modules = discover_modules(monorepo_root)
    else:
        modules = [m.strip() for m in args.modules.split(",") if m.strip()]

    if not modules:
        print("error: no modules specified", file=sys.stderr)
        return 1

    # Build remote base (trailing slash normalised away)
    if args.remote_base:
        remote_base = args.remote_base.rstrip("/")
    else:
        token = os.environ.get("GITHUB_TOKEN")
        if not token:
            print(
                "error: GITHUB_TOKEN is required when --remote-base is not set",
                file=sys.stderr,
            )
            return 1
        remote_base = "https://x-access-token:%s@github.com/%s" % (token, args.org)

    results = []
    for module in modules:
        remote = "%s/%s.git" % (remote_base, module)
        result = freeze_module(module, remote, dry_run=args.dry_run)
        results.append(result)

    # Summary table
    col_w = max(len(r["module"]) for r in results)
    print("\n%-*s  %s" % (col_w, "module", "status"))
    print("-" * (col_w + 30))
    any_failed = False
    for r in results:
        print("%-*s  %s" % (col_w, r["module"], r["status"]))
        if r["status"].startswith("FAILED"):
            any_failed = True

    # Write report
    report_path = Path(args.report)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    with report_path.open("w", encoding="utf-8") as fh:
        json.dump(results, fh, indent=2)

    return 1 if any_failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
