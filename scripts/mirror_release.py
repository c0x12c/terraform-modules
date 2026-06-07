#!/usr/bin/env python3

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path


DEFAULT_VALIDATE_CMD = (
    "terraform fmt -check -recursive && "
    "terraform init -backend=false -input=false && "
    "terraform validate"
)

SIBLING_SOURCE_RE = re.compile(
    r'^(\s*source\s*=\s*")\.\./(terraform-[A-Za-z0-9_-]+)(".*?)(\r?\n?)$'
)
RELATIVE_SOURCE_RE = re.compile(r'^\s*source\s*=\s*"\.{1,2}/')

EXIT_MAPPING = 11
EXIT_MANIFEST = 12
EXIT_LEFTOVER_RELATIVE = 13
EXIT_IDENTITY = 14
EXIT_VALIDATE = 15
EXIT_TAG_CONFLICT = 16
EXIT_GIT = 17


class MirrorError(Exception):
    exit_code = 1
    failure_class = "mirror"


class MappingError(MirrorError):
    exit_code = EXIT_MAPPING
    failure_class = "mapping"


class ManifestError(MirrorError):
    exit_code = EXIT_MANIFEST
    failure_class = "manifest-missing"


class LeftoverRelativeSourceError(MirrorError):
    exit_code = EXIT_LEFTOVER_RELATIVE
    failure_class = "leftover-relative"


class IdentityError(MirrorError):
    exit_code = EXIT_IDENTITY
    failure_class = "identity"


class ValidateError(MirrorError):
    exit_code = EXIT_VALIDATE
    failure_class = "validate"


class TagConflictError(MirrorError):
    exit_code = EXIT_TAG_CONFLICT
    failure_class = "tag-conflict"


class GitError(MirrorError):
    exit_code = EXIT_GIT
    failure_class = "git"


@dataclass(frozen=True)
class ModuleMapping:
    provider: str
    name: str
    registry_source: str


def module_to_registry(module: str, org: str) -> ModuleMapping:
    parts = module.split("-")
    if len(parts) < 3 or parts[0] != "terraform" or not parts[1] or not parts[2]:
        raise MappingError(
            "mapping: module name must match terraform-<provider>-<name>: %s" % module
        )
    provider = parts[1]
    name = "-".join(parts[2:])
    if not name:
        raise MappingError(
            "mapping: module name must match terraform-<provider>-<name>: %s" % module
        )
    return ModuleMapping(
        provider=provider,
        name=name,
        registry_source="%s/%s/%s" % (org, name, provider),
    )


def normalize_version(value: str) -> str:
    return value[1:] if value.startswith("v") else value


_EXAMPLES_DIRS = {"examples", "test", "tests"}


def _is_examples_path(rel_path: str) -> bool:
    """Return True if rel_path is under examples/, test/, or tests/ (relative to module root)."""
    parts = Path(rel_path).parts
    return bool(parts) and parts[0] in _EXAMPLES_DIRS


def rewrite_tf_text(text: str, manifest: dict, org: str, rel_path: str = "") -> str:
    # Files under examples/, test/, tests/ are copied verbatim — no rewrite, no relative-source check.
    if rel_path and _is_examples_path(rel_path):
        return text

    lines = text.splitlines(True)
    output = []
    for line in lines:
        match = SIBLING_SOURCE_RE.match(line)
        if match:
            sibling_module = match.group(2)
            sibling_mapping = module_to_registry(sibling_module, org)
            sibling_version = manifest.get(sibling_module)
            if sibling_version is None:
                raise ManifestError(
                    "manifest-missing: sibling %s not found in manifest" % sibling_module
                )
            newline = "\n"
            if line.endswith("\r\n"):
                newline = "\r\n"
            elif line.endswith("\n"):
                newline = "\n"
            indent_match = re.match(r"^(\s*)", line)
            indent = indent_match.group(1) if indent_match else ""
            rewritten_line = (
                '%ssource = "%s"%s'
                % (indent, sibling_mapping.registry_source, newline)
            )
            version_line = '%sversion = "%s"%s' % (
                indent,
                normalize_version(str(sibling_version)),
                newline,
            )
            output.append(rewritten_line)
            output.append(version_line)
            continue
        output.append(line)
    rewritten = "".join(output)
    for rewritten_line in rewritten.splitlines():
        if RELATIVE_SOURCE_RE.match(rewritten_line):
            raise LeftoverRelativeSourceError(
                "leftover-relative: relative module source remains: %s"
                % rewritten_line.strip()
            )
    return rewritten


def load_manifest(path: Path) -> dict:
    try:
        with path.open("r", encoding="utf-8") as handle:
            data = json.load(handle)
    except FileNotFoundError as exc:
        raise ManifestError("manifest-missing: file not found: %s" % path) from exc
    if not isinstance(data, dict):
        raise ManifestError("manifest-missing: manifest must be a JSON object")
    return data


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
            % (" ".join(["git"] + list(args)), completed.stderr.strip())
        )
    return completed


def clone_mirror(remote: str, destination: Path) -> None:
    run_git(["clone", remote, str(destination)])
    remote_head = run_git(
        ["symbolic-ref", "--short", "refs/remotes/origin/HEAD"],
        cwd=destination,
        check=False,
    )
    start_point = "origin/master"
    if remote_head.returncode == 0 and remote_head.stdout.strip():
        start_point = remote_head.stdout.strip()
    run_git(["checkout", "-B", "master", start_point], cwd=destination)


def assert_mirror_identity(clone_dir: Path, module: str) -> None:
    remote_url = run_git(["remote", "get-url", "origin"], cwd=clone_dir).stdout.strip()
    normalized = remote_url.rstrip("/")
    if not (
        normalized.endswith("/%s" % module) or normalized.endswith("/%s.git" % module)
    ):
        raise IdentityError(
            "identity: remote %s does not match expected module %s"
            % (remote_url, module)
        )


def clear_worktree(worktree: Path) -> None:
    for child in worktree.iterdir():
        if child.name == ".git":
            continue
        if child.is_dir():
            shutil.rmtree(child)
        else:
            child.unlink()


def copy_module_contents(source_dir: Path, dest_dir: Path) -> None:
    clear_worktree(dest_dir)
    for child in source_dir.iterdir():
        if child.name in {".git", ".terraform", ".terraform.lock.hcl"}:
            continue
        target = dest_dir / child.name
        if child.is_dir():
            shutil.copytree(child, target, dirs_exist_ok=False)
        else:
            shutil.copy2(child, target)


def rewrite_worktree_tf_files(worktree: Path, manifest: dict, org: str) -> None:
    for tf_file in sorted(worktree.rglob("*.tf")):
        if ".git" in tf_file.parts:
            continue
        rel_path = tf_file.relative_to(worktree).as_posix()
        original = tf_file.read_text(encoding="utf-8")
        rewritten = rewrite_tf_text(original, manifest, org, rel_path=rel_path)
        if rewritten != original:
            tf_file.write_text(rewritten, encoding="utf-8")


def run_validation(worktree: Path, validate_cmd: str) -> None:
    completed = subprocess.run(
        ["sh", "-lc", validate_cmd],
        cwd=str(worktree),
        check=False,
        text=True,
        capture_output=True,
    )
    if completed.returncode != 0:
        raise ValidateError(
            "validate: command failed with exit %s: %s"
            % (
                completed.returncode,
                (completed.stderr or completed.stdout).strip(),
            )
        )


def remove_generated_terraform_artifacts(root: Path) -> None:
    for lock_file in root.rglob(".terraform.lock.hcl"):
        if ".git" in lock_file.parts:
            continue
        if lock_file.is_file():
            lock_file.unlink()
    terraform_dirs = sorted(
        (path for path in root.rglob(".terraform") if ".git" not in path.parts),
        key=lambda path: len(path.parts),
        reverse=True,
    )
    for terraform_dir in terraform_dirs:
        if terraform_dir.is_dir():
            shutil.rmtree(terraform_dir)


def snapshot_worktree(root: Path) -> dict:
    snapshot = {}
    excluded = {".git", ".terraform", ".terraform.lock.hcl"}
    for path in sorted(root.rglob("*")):
        if path.is_dir():
            continue
        if any(part in excluded for part in path.parts):
            continue
        rel_path = path.relative_to(root).as_posix()
        snapshot[rel_path] = path.read_bytes()
    return snapshot


def git_ref_exists(repo: Path, ref: str) -> bool:
    completed = run_git(
        ["rev-parse", "--verify", "--quiet", ref],
        cwd=repo,
        check=False,
    )
    return completed.returncode == 0


def snapshot_git_tree(repo: Path, ref: str) -> dict:
    listing = run_git(
        ["ls-tree", "-r", "--full-tree", ref],
        cwd=repo,
    ).stdout.strip()
    snapshot = {}
    if not listing:
        return snapshot
    for line in listing.splitlines():
        _meta, rel_path = line.split("\t", 1)
        blob = subprocess.run(
            ["git", "show", "%s:%s" % (ref, rel_path)],
            cwd=str(repo),
            check=False,
            capture_output=True,
        )
        if blob.returncode != 0:
            raise GitError(
                "git: failed to read %s from %s: %s"
                % (rel_path, ref, blob.stderr.decode("utf-8", "replace").strip())
            )
        snapshot[rel_path] = blob.stdout
    return snapshot


def worktree_has_changes(repo: Path) -> bool:
    completed = run_git(["status", "--porcelain"], cwd=repo)
    return bool(completed.stdout.strip())


def ensure_git_identity(repo: Path) -> None:
    run_git(["config", "user.name", "monorepo-mirror"], cwd=repo)
    run_git(["config", "user.email", "monorepo-mirror@example.invalid"], cwd=repo)


def commit_changes(repo: Path, module: str, version: str) -> bool:
    if not worktree_has_changes(repo):
        return False
    ensure_git_identity(repo)
    run_git(["add", "-A"], cwd=repo)
    run_git(
        ["commit", "-m", "chore: mirror %s %s from monorepo" % (module, version)],
        cwd=repo,
    )
    return True


def push_master(repo: Path) -> None:
    run_git(["push", "origin", "master"], cwd=repo)


def ensure_tag(repo: Path, version: str) -> None:
    if not git_ref_exists(repo, "refs/tags/%s" % version):
        run_git(["tag", version], cwd=repo)
    run_git(["push", "origin", version], cwd=repo)


def default_remote(org: str, module: str) -> str:
    token = os.environ.get("GITHUB_TOKEN", "$GITHUB_TOKEN")
    return "https://x-access-token:%s@github.com/%s/%s.git" % (token, org, module)


def parse_args(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument("--module", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--mirror-remote")
    parser.add_argument("--monorepo-root", default=os.getcwd())
    parser.add_argument("--manifest")
    parser.add_argument("--validate-cmd", default=DEFAULT_VALIDATE_CMD)
    parser.add_argument("--org", default="c0x12c")
    return parser.parse_args(argv)


def main(argv=None) -> int:
    args = parse_args(argv or sys.argv[1:])
    module = args.module
    monorepo_root = Path(args.monorepo_root).resolve()
    manifest_path = (
        Path(args.manifest).resolve()
        if args.manifest
        else monorepo_root / ".release-please-manifest.json"
    )
    module_dir = monorepo_root / module
    if not module_dir.is_dir():
        raise MappingError("mapping: module directory does not exist: %s" % module_dir)
    module_to_registry(module, args.org)
    manifest = load_manifest(manifest_path)
    remote = args.mirror_remote or default_remote(args.org, module)

    with tempfile.TemporaryDirectory(prefix="mirror-release-") as temp_dir:
        clone_dir = Path(temp_dir) / "mirror"
        clone_mirror(remote, clone_dir)
        assert_mirror_identity(clone_dir, module)
        copy_module_contents(module_dir, clone_dir)
        rewrite_worktree_tf_files(clone_dir, manifest, args.org)
        run_validation(clone_dir, args.validate_cmd)
        remove_generated_terraform_artifacts(clone_dir)

        tag_ref = "refs/tags/%s" % args.version
        if git_ref_exists(clone_dir, tag_ref):
            current_snapshot = snapshot_worktree(clone_dir)
            tag_snapshot = snapshot_git_tree(clone_dir, args.version)
            if current_snapshot == tag_snapshot:
                print("already mirrored: %s %s" % (module, args.version))
                return 0
            raise TagConflictError(
                "tag-conflict: tag %s exists with different content" % args.version
            )

        commit_changes(clone_dir, module, args.version)
        push_master(clone_dir)
        ensure_tag(clone_dir, args.version)

    print("mirrored: %s %s" % (module, args.version))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except MirrorError as exc:
        print(str(exc), file=sys.stderr)
        raise SystemExit(exc.exit_code)
