#!/usr/bin/env python3

import argparse
import configparser
import json
import os
import shlex
import shutil
import subprocess
import sys
import tarfile
import tempfile
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path


@dataclass(frozen=True)
class Submodule:
    name: str
    path: str
    url: str


@dataclass
class ModuleResult:
    module: str
    status: str
    imported_sha: str = ""
    imported_sha_short: str = ""
    unreleased_delta: str = ""
    tags: str = ""
    manifest: str = ""
    message: str = ""


def git_command(args):
    extra = shlex.split(os.environ.get("SQUASH_IMPORT_GIT_FLAGS", ""))
    return ["git"] + extra + list(args)


def run_git(args, cwd=None, check=True, capture_output=True, text=True):
    completed = subprocess.run(
        git_command(args),
        cwd=str(cwd) if cwd else None,
        check=False,
        capture_output=capture_output,
        text=text,
    )
    if check and completed.returncode != 0:
        stderr = completed.stderr.strip() if completed.stderr else ""
        stdout = completed.stdout.strip() if completed.stdout else ""
        detail = stderr or stdout or "unknown git failure"
        raise RuntimeError(
            "git command failed (%s): %s"
            % (" ".join(git_command(args)), detail)
        )
    return completed


def load_manifest(path: Path) -> dict:
    if not path.exists():
        return {}
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise RuntimeError("manifest must be a JSON object: %s" % path)
    return data


def parse_gitmodules(path: Path):
    if not path.exists():
        return []
    parser = configparser.ConfigParser()
    parser.read(path, encoding="utf-8")
    modules = []
    for section in parser.sections():
        prefix = 'submodule "'
        if not section.startswith(prefix) or not section.endswith('"'):
            continue
        name = section[len(prefix) : -1]
        modules.append(
            Submodule(
                name=name,
                path=parser.get(section, "path"),
                url=parser.get(section, "url"),
            )
        )
    return modules


def write_gitmodules(path: Path, modules) -> None:
    lines = []
    for module in modules:
        lines.extend(
            [
                '[submodule "%s"]\n' % module.name,
                "\tpath = %s\n" % module.path,
                "\turl = %s\n" % module.url,
            ]
        )
    path.write_text("".join(lines), encoding="utf-8")


def module_lookup(modules):
    return {module.name: module for module in modules}


def get_index_gitlink_sha(repo_root: Path, module_path: str):
    completed = run_git(
        ["ls-files", "--stage", "--", module_path],
        cwd=repo_root,
        check=False,
    )
    for line in completed.stdout.splitlines():
        parts = line.split()
        if len(parts) >= 4 and parts[0] == "160000":
            return parts[1]
    return None


def ensure_submodule_initialized(repo_root: Path, module_path: str) -> None:
    git_dir = repo_root / module_path / ".git"
    if git_dir.exists():
        return
    run_git(["submodule", "update", "--init", "--", module_path], cwd=repo_root)


def has_reachable_version_tags(module_dir: Path, sha: str) -> bool:
    completed = run_git(
        ["tag", "--merged", sha, "-l", "v*"],
        cwd=module_dir,
        check=False,
    )
    return bool(completed.stdout.strip())


def export_tree(module_dir: Path, sha: str, destination: Path) -> None:
    completed = run_git(
        ["archive", "--format=tar", sha],
        cwd=module_dir,
        text=False,
    )
    with tarfile.open(fileobj=BytesIO(completed.stdout), mode="r:*") as archive:
        archive.extractall(destination)


def remove_path(path: Path) -> None:
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    elif path.exists() or path.is_symlink():
        path.unlink()


def clear_directory(path: Path) -> None:
    for child in path.iterdir():
        remove_path(child)


def remove_git_metadata(module_dir: Path) -> None:
    git_path = module_dir / ".git"
    if git_path.exists() or git_path.is_symlink():
        remove_path(git_path)


def resolve_module(repo_root: Path, module_path: str):
    ensure_submodule_initialized(repo_root, module_path)
    module_dir = repo_root / module_path
    run_git(["fetch", "--tags", "origin", "master"], cwd=module_dir)
    imported_sha = run_git(["rev-parse", "FETCH_HEAD"], cwd=module_dir).stdout.strip()
    recorded_sha = get_index_gitlink_sha(repo_root, module_path)
    unreleased_delta = "yes" if recorded_sha and recorded_sha != imported_sha else "no"
    tags = "yes" if has_reachable_version_tags(module_dir, imported_sha) else "none"
    return imported_sha, unreleased_delta, tags


def materialize_module(repo_root: Path, module_path: str, imported_sha: str) -> None:
    module_dir = repo_root / module_path
    with tempfile.TemporaryDirectory(prefix="squash-import-") as temp_dir:
        temp_path = Path(temp_dir)
        export_tree(module_dir, imported_sha, temp_path)
        run_git(["submodule", "deinit", "-f", "--", module_path], cwd=repo_root)
        run_git(["rm", "--cached", "-r", "--", module_path], cwd=repo_root)
        module_dir.mkdir(parents=True, exist_ok=True)
        clear_directory(module_dir)
        for child in temp_path.iterdir():
            target = module_dir / child.name
            if child.is_dir():
                shutil.copytree(child, target)
            else:
                shutil.copy2(child, target)
        remove_git_metadata(module_dir)
        github_dir = module_dir / ".github"
        if github_dir.exists():
            shutil.rmtree(github_dir)
        run_git(["add", "--", module_path], cwd=repo_root)


def update_gitmodules_after_success(repo_root: Path, removed_names) -> None:
    gitmodules_path = repo_root / ".gitmodules"
    remaining = [
        module
        for module in parse_gitmodules(gitmodules_path)
        if module.name not in removed_names
    ]
    if remaining:
        write_gitmodules(gitmodules_path, remaining)
        run_git(["add", ".gitmodules"], cwd=repo_root)
    elif gitmodules_path.exists():
        run_git(["rm", "--", ".gitmodules"], cwd=repo_root)


def choose_modules(repo_root: Path, requested_modules):
    configured = parse_gitmodules(repo_root / ".gitmodules")
    configured_by_name = module_lookup(configured)
    if not requested_modules:
        return configured
    selected = []
    for name in requested_modules:
        module = configured_by_name.get(name)
        if module:
            selected.append(module)
        else:
            selected.append(Submodule(name=name, path=name, url=""))
    return selected


def render_summary(results, failures):
    headers = ["module", "imported_sha", "unreleased_delta", "tags", "manifest", "status"]
    rows = []
    for result in results:
        rows.append(
            [
                result.module,
                result.imported_sha_short,
                result.unreleased_delta,
                result.tags,
                result.manifest,
                result.status,
            ]
        )
    widths = [len(header) for header in headers]
    for row in rows:
        for index, value in enumerate(row):
            widths[index] = max(widths[index], len(value))
    format_row = "  ".join("%%-%ds" % width for width in widths)
    print(format_row % tuple(headers))
    for row in rows:
        print(format_row % tuple(row))
    for result in results:
        if result.message:
            print("%s: %s" % (result.module, result.message))
    if failures:
        print("failures:")
        for failure in failures:
            print("  %s: %s" % (failure["module"], failure["error"]))


def write_summary(summary_path: Path, results, failures):
    summary_path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "results": [
            {
                "module": result.module,
                "status": result.status,
                "imported_sha": result.imported_sha,
                "imported_sha_short": result.imported_sha_short,
                "unreleased_delta": result.unreleased_delta,
                "tags": result.tags,
                "manifest": result.manifest,
                "message": result.message,
            }
            for result in results
        ],
        "failures": failures,
    }
    summary_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def process_modules(repo_root: Path, requested_modules, manifest_path: Path, dry_run: bool):
    manifest = load_manifest(manifest_path)
    results = []
    failures = []
    successful_configured = []

    for module in choose_modules(repo_root, requested_modules):
        manifest_status = "yes" if module.name in manifest else "MISSING"
        gitlink_sha = get_index_gitlink_sha(repo_root, module.path)
        configured = any(item.name == module.name for item in parse_gitmodules(repo_root / ".gitmodules"))
        if not configured and not gitlink_sha:
            results.append(
                ModuleResult(
                    module=module.name,
                    status="skipped",
                    manifest=manifest_status,
                    message="already converted",
                )
            )
            continue
        try:
            imported_sha, unreleased_delta, tags = resolve_module(repo_root, module.path)
            result = ModuleResult(
                module=module.name,
                status="planned" if dry_run else "converted",
                imported_sha=imported_sha,
                imported_sha_short=imported_sha[:12],
                unreleased_delta=unreleased_delta,
                tags=tags,
                manifest=manifest_status,
            )
            if manifest_status == "MISSING":
                result.message = "missing from manifest"
            if not dry_run:
                materialize_module(repo_root, module.path, imported_sha)
                if configured:
                    successful_configured.append(module.name)
            results.append(result)
        except Exception as exc:
            failures.append({"module": module.name, "error": str(exc)})
            results.append(
                ModuleResult(
                    module=module.name,
                    status="failed",
                    manifest=manifest_status,
                    message=str(exc),
                )
            )

    if not dry_run and successful_configured:
        update_gitmodules_after_success(repo_root, set(successful_configured))

    return results, failures


def parse_args(argv=None):
    parser = argparse.ArgumentParser(description="Convert git submodules into plain folders.")
    parser.add_argument("--repo-root", default=".", help="Repository root containing .gitmodules")
    parser.add_argument(
        "--modules",
        help="Comma-separated list of submodule names to process",
    )
    parser.add_argument(
        "--manifest",
        default=".module-versions.json",
        help="Path to release manifest relative to repo root or absolute",
    )
    parser.add_argument("--dry-run", action="store_true", help="Print actions without mutating the repo")
    return parser.parse_args(argv)


def main(argv=None):
    args = parse_args(argv)
    repo_root = Path(args.repo_root).resolve()
    requested_modules = None
    if args.modules:
        requested_modules = [item.strip() for item in args.modules.split(",") if item.strip()]
    manifest_path = Path(args.manifest)
    if not manifest_path.is_absolute():
        manifest_path = repo_root / manifest_path

    try:
        results, failures = process_modules(
            repo_root=repo_root,
            requested_modules=requested_modules,
            manifest_path=manifest_path,
            dry_run=args.dry_run,
        )
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 1

    render_summary(results, failures)
    write_summary(repo_root / ".agent" / "import-summary.json", results, failures)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
