#!/usr/bin/env python3
"""Publish a monorepo module to the self-hosted R2 Terraform registry.

Assembles the module from the monorepo, rewrites sibling sources to registry
form, runs terraform validation, and uploads the tarball plus its index.json
entry to R2. No GitHub mirror repo is touched — R2 is the only target.
"""

import argparse
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
from dataclasses import dataclass
from pathlib import Path


DEFAULT_VALIDATE_CMD = (
    "terraform fmt -check -recursive && "
    "terraform init -backend=false -input=false && "
    "terraform validate"
)
REGISTRY_HOST = "terraform.c0x12c.com"

SIBLING_SOURCE_RE = re.compile(
    r'^(\s*source\s*=\s*")\.\./(terraform-[A-Za-z0-9_-]+)(".*?)(\r?\n?)$'
)
# Only parent-escaping sources are forbidden in the published tarball. A
# "./<subdir>" source stays inside the module folder and resolves fine.
RELATIVE_SOURCE_RE = re.compile(r'^\s*source\s*=\s*"(\.\./|\./\.\./)')

EXIT_MAPPING = 11
EXIT_MANIFEST = 12
EXIT_LEFTOVER_RELATIVE = 13
EXIT_VALIDATE = 15


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


class ValidateError(MirrorError):
    exit_code = EXIT_VALIDATE
    failure_class = "validate"


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
            # `terraform fmt` aligns the "=" of the consecutive source/version
            # assignments to the longest key ("version"), so emit them
            # pre-aligned. Otherwise `terraform fmt -check` rejects the mirror
            # (exit 3) during validation.
            key_width = len("version")
            rewritten_line = '%s%s = "%s"%s' % (
                indent,
                "source".ljust(key_width),
                "%s/%s" % (REGISTRY_HOST, sibling_mapping.registry_source),
                newline,
            )
            version_line = '%s%s = "%s"%s' % (
                indent,
                "version".ljust(key_width),
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


def upload_to_r2(clone_dir: Path, module: str, version: str, bucket: str, org: str) -> None:
    import boto3

    client = boto3.client("s3", endpoint_url=os.environ["R2_ENDPOINT"])
    ver = version.lstrip("v")
    key = module_to_registry(module, org).registry_source

    tar_buffer = io.BytesIO()
    with tarfile.open(fileobj=tar_buffer, mode="w:gz") as archive:
        for path in sorted(clone_dir.rglob("*")):
            rel_path = path.relative_to(clone_dir)
            if rel_path.parts and rel_path.parts[0] == ".git":
                continue
            archive.add(path, arcname=rel_path.as_posix(), recursive=False)
    client.put_object(
        Bucket=bucket,
        Key="modules/%s/%s.tar.gz" % (key, ver),
        Body=tar_buffer.getvalue(),
        ContentType="application/gzip",
    )

    try:
        body = client.get_object(Bucket=bucket, Key="index.json")["Body"].read()
        index = json.loads(body.decode("utf-8"))
    except client.exceptions.NoSuchKey:
        index = {}

    versions = set(index.get(key, []))
    versions.add(ver)
    index[key] = sorted(
        versions,
        key=lambda value: tuple(int(part) for part in value.split(".")),
    )
    client.put_object(
        Bucket=bucket,
        Key="index.json",
        Body=(json.dumps(index, indent=2) + "\n").encode("utf-8"),
        ContentType="application/json",
    )
    print("r2-published %s %s -> %s" % (module, ver, key))


def assemble_r2_tree(
    module_dir: Path, dest: Path, manifest: dict, org: str, validate_cmd: str
) -> None:
    """Build the rewritten, validated module tree for R2 packing.

    The R2-only counterpart to the mirror assembly: copy the module from the
    monorepo, rewrite sibling sources, run terraform validation, and strip
    generated artifacts — with NO git clone, NO mirror identity check, and NO
    readme banner (the banner's "read-only mirror" wording is mirror-specific).
    """
    copy_module_contents(module_dir, dest)
    rewrite_worktree_tf_files(dest, manifest, org)
    run_validation(dest, validate_cmd)
    remove_generated_terraform_artifacts(dest)


def parse_args(argv):
    parser = argparse.ArgumentParser(
        description="Publish a monorepo module to the self-hosted R2 Terraform "
        "registry: assemble the module, rewrite sibling sources to registry "
        "form, run terraform validation, and upload the tarball plus its "
        "index.json entry. Does not touch any mirror repo.",
    )
    parser.add_argument(
        "--module", required=True,
        help="module directory name in the monorepo, e.g. terraform-aws-rds",
    )
    parser.add_argument(
        "--version", required=True,
        help="version to publish, e.g. v1.2.0 (a leading 'v' is optional)",
    )
    parser.add_argument(
        "--r2-bucket",
        help="R2 bucket to publish into (required unless --dry-run)",
    )
    parser.add_argument(
        "--org", default="c0x12c",
        help="registry namespace / GitHub org (default: c0x12c)",
    )
    parser.add_argument(
        "--monorepo-root", default=os.getcwd(),
        help="path to the monorepo checkout (default: current directory)",
    )
    parser.add_argument(
        "--manifest",
        help="versions manifest path "
        "(default: <monorepo-root>/.module-versions.json)",
    )
    parser.add_argument(
        "--validate-cmd", default=DEFAULT_VALIDATE_CMD,
        help="shell command run to validate the assembled module",
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="assemble and validate the module but do NOT upload to R2 — "
        "use to verify a release safely",
    )
    args = parser.parse_args(argv)
    if not args.dry_run and not args.r2_bucket:
        parser.error("--r2-bucket is required unless --dry-run is set")
    return args


def main(argv=None) -> int:
    args = parse_args(argv or sys.argv[1:])
    module = args.module
    monorepo_root = Path(args.monorepo_root).resolve()
    manifest_path = (
        Path(args.manifest).resolve()
        if args.manifest
        else monorepo_root / ".module-versions.json"
    )
    module_dir = monorepo_root / module
    if not module_dir.is_dir():
        raise MappingError("mapping: module directory does not exist: %s" % module_dir)
    module_to_registry(module, args.org)
    manifest = load_manifest(manifest_path)

    with tempfile.TemporaryDirectory(prefix="r2-publish-") as temp_dir:
        work = Path(temp_dir) / "module"
        work.mkdir(parents=True)
        assemble_r2_tree(module_dir, work, manifest, args.org, args.validate_cmd)
        if args.dry_run:
            print("dry-run: assembled and validated %s %s (not uploaded)"
                  % (module, args.version))
            return 0
        upload_to_r2(work, module, args.version, args.r2_bucket, args.org)

    print("published %s %s to the R2 registry" % (module, args.version))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except MirrorError as exc:
        print(str(exc), file=sys.stderr)
        raise SystemExit(exc.exit_code)
