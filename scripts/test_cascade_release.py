#!/usr/bin/env python3

import json
import subprocess
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))

from cascade_release import (  # noqa: E402
    CascadeError,
    cascade,
    discover_parents,
    update_stamp,
)


def _write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def make_repo(tmp_path: Path) -> Path:
    root = tmp_path / "repo"
    root.mkdir()
    subprocess.run(["git", "init", "-q"], cwd=root, check=True)
    subprocess.run(["git", "config", "user.email", "test@test"], cwd=root, check=True)
    subprocess.run(["git", "config", "user.name", "test"], cwd=root, check=True)

    _write(root / "terraform-aws-leaf/main.tf", 'resource "x" "y" {}\n')
    _write(
        root / "terraform-aws-parent/main.tf",
        'module "leaf" {\n  source = "../terraform-aws-leaf"\n}\n',
    )
    _write(
        root / "terraform-aws-other/main.tf",
        'module "z" {\n  source = "c0x12c/something/aws"\n}\n',
    )
    # Exempt dir reference must NOT count as a parent.
    _write(
        root / "terraform-aws-examples-only/examples/main.tf",
        'module "leaf" {\n  source = "../terraform-aws-leaf"\n}\n',
    )
    subprocess.run(["git", "add", "-A"], cwd=root, check=True)
    subprocess.run(["git", "commit", "-qm", "init"], cwd=root, check=True)
    return root


def test_discover_parents_finds_direct_consumer(tmp_path):
    root = make_repo(tmp_path)
    assert discover_parents(root, "terraform-aws-leaf") == ["terraform-aws-parent"]


def test_discover_parents_ignores_exempt_dirs(tmp_path):
    root = make_repo(tmp_path)
    parents = discover_parents(root, "terraform-aws-leaf")
    assert "terraform-aws-examples-only" not in parents


def test_discover_parents_excludes_self(tmp_path):
    root = make_repo(tmp_path)
    # Pathological self-reference must not cascade into itself.
    _write(
        root / "terraform-aws-leaf/self.tf",
        'module "me" {\n  source = "../terraform-aws-leaf"\n}\n',
    )
    assert "terraform-aws-leaf" not in discover_parents(root, "terraform-aws-leaf")


def test_update_stamp_creates_and_merges(tmp_path):
    root = make_repo(tmp_path)
    parent = root / "terraform-aws-parent"
    assert update_stamp(parent, "terraform-aws-leaf", "v1.0.1") is True
    assert update_stamp(parent, "terraform-aws-other", "v2.0.0") is True
    stamps = json.loads((parent / ".sibling-versions").read_text())
    assert stamps == {
        "terraform-aws-leaf": "v1.0.1",
        "terraform-aws-other": "v2.0.0",
    }


def test_update_stamp_idempotent(tmp_path):
    root = make_repo(tmp_path)
    parent = root / "terraform-aws-parent"
    assert update_stamp(parent, "terraform-aws-leaf", "v1.0.1") is True
    assert update_stamp(parent, "terraform-aws-leaf", "v1.0.1") is False


def test_update_stamp_rejects_corrupt_file(tmp_path):
    root = make_repo(tmp_path)
    parent = root / "terraform-aws-parent"
    (parent / ".sibling-versions").write_text("not json")
    with pytest.raises(CascadeError):
        update_stamp(parent, "terraform-aws-leaf", "v1.0.1")


def test_dry_run_mutates_nothing(tmp_path):
    root = make_repo(tmp_path)
    bumped = cascade(root, "terraform-aws-leaf", "v1.0.1", execute=False)
    assert bumped == ["terraform-aws-parent"]
    assert not (root / "terraform-aws-parent/.sibling-versions").exists()
    status = subprocess.run(
        ["git", "status", "--porcelain"], cwd=root, check=True,
        capture_output=True, text=True,
    )
    assert status.stdout.strip() == ""


def test_execute_commits_one_per_parent(tmp_path):
    root = make_repo(tmp_path)
    # Second parent to verify one-commit-per-parent.
    _write(
        root / "terraform-aws-parent2/main.tf",
        'module "leaf" {\n  source = "../terraform-aws-leaf"\n}\n',
    )
    subprocess.run(["git", "add", "-A"], cwd=root, check=True)
    subprocess.run(["git", "commit", "-qm", "add parent2"], cwd=root, check=True)

    bumped = cascade(root, "terraform-aws-leaf", "v1.0.1", execute=True, push=False)
    assert bumped == ["terraform-aws-parent", "terraform-aws-parent2"]

    log = subprocess.run(
        ["git", "log", "--format=%s", "-2"], cwd=root, check=True,
        capture_output=True, text=True,
    ).stdout.splitlines()
    assert log == [
        "fix(deps): bump terraform-aws-leaf to v1.0.1 in terraform-aws-parent2",
        "fix(deps): bump terraform-aws-leaf to v1.0.1 in terraform-aws-parent",
    ]


def test_execute_skips_already_recorded(tmp_path):
    root = make_repo(tmp_path)
    parent = root / "terraform-aws-parent"
    _write(parent / ".sibling-versions", '{"terraform-aws-leaf": "v1.0.1"}\n')
    subprocess.run(["git", "add", "-A"], cwd=root, check=True)
    subprocess.run(["git", "commit", "-qm", "stamp"], cwd=root, check=True)

    bumped = cascade(root, "terraform-aws-leaf", "v1.0.1", execute=True, push=False)
    assert bumped == []


def test_rejects_unknown_module(tmp_path):
    root = make_repo(tmp_path)
    with pytest.raises(CascadeError):
        cascade(root, "terraform-aws-missing", "v1.0.0", execute=False)


def test_rejects_bad_version(tmp_path):
    root = make_repo(tmp_path)
    with pytest.raises(CascadeError):
        cascade(root, "terraform-aws-leaf", "1.0.0", execute=False)
