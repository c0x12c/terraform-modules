#!/usr/bin/env python3

import json
import subprocess
import sys
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent / "check_module_drift.py"


def make_repo(tmp_path: Path, disk, config, versions) -> Path:
    for name in disk:
        (tmp_path / name).mkdir(parents=True, exist_ok=True)
    (tmp_path / "module-release-config.json").write_text(
        json.dumps({"packages": {n: {} for n in config}}), encoding="utf-8")
    (tmp_path / ".module-versions.json").write_text(
        json.dumps({n: "1.0.0" for n in versions}), encoding="utf-8")
    return tmp_path


def run(root: Path):
    return subprocess.run(
        [sys.executable, str(SCRIPT), "--repo-root", str(root)],
        capture_output=True, text=True)


def test_in_sync_passes(tmp_path):
    mods = ["terraform-aws-rds", "terraform-aws-vpc"]
    root = make_repo(tmp_path, mods, mods, mods)
    r = run(root)
    assert r.returncode == 0, r.stderr
    assert "in sync" in r.stdout


def test_module_missing_from_config_fails(tmp_path):
    root = make_repo(
        tmp_path,
        disk=["terraform-aws-rds", "terraform-aws-vpc"],
        config=["terraform-aws-rds"],            # vpc missing in config
        versions=["terraform-aws-rds", "terraform-aws-vpc"])
    r = run(root)
    assert r.returncode == 1
    assert "terraform-aws-vpc" in r.stderr
    assert "module-release-config.json" in r.stderr


def test_module_missing_from_disk_fails(tmp_path):
    root = make_repo(
        tmp_path,
        disk=["terraform-aws-rds"],
        config=["terraform-aws-rds", "terraform-aws-ghost"],
        versions=["terraform-aws-rds", "terraform-aws-ghost"])
    r = run(root)
    assert r.returncode == 1
    assert "terraform-aws-ghost" in r.stderr
    assert "missing on disk" in r.stderr


def test_non_module_dirs_ignored(tmp_path):
    mods = ["terraform-aws-rds"]
    root = make_repo(tmp_path, mods, mods, mods)
    (root / "scripts").mkdir()        # non terraform-* dir must be ignored
    (root / "docs").mkdir()
    r = run(root)
    assert r.returncode == 0, r.stderr
