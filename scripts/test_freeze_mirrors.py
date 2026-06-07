#!/usr/bin/env python3
"""Unit tests for freeze_mirrors.py — local bare-repo fixtures only, never real remotes."""

import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

from scripts.freeze_mirrors import (
    FREEZE_COMMIT_MSG,
    FreezeError,
    GitError,
    IdentityError,
    assert_mirror_identity,
    clone_shallow,
    compute_removals,
    freeze_module,
    main,
    run_git,
)


# ── Fixture helpers ───────────────────────────────────────────────────────────

def _git(*args, cwd):
    """Run a git command; raise on failure."""
    result = subprocess.run(
        ["git"] + list(args),
        cwd=str(cwd),
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def _make_bare_repo(root: Path, name: str) -> Path:
    """Create a bare git repo at root/name.git and return its path."""
    bare = root / ("%s.git" % name)
    bare.mkdir(parents=True)
    _git("init", "--bare", str(bare), cwd=root)
    return bare


def _seed_repo(bare: Path, files: dict) -> None:
    """
    Push an initial commit to *bare* with the given files (relative path -> content str).
    Creates a temporary clone, commits, and pushes as master.
    """
    with tempfile.TemporaryDirectory(prefix="seed-") as tmp:
        work = Path(tmp) / "work"
        _git("clone", str(bare), str(work), cwd=tmp)
        _git("config", "user.name", "test", cwd=work)
        _git("config", "user.email", "test@example.invalid", cwd=work)
        for rel, content in files.items():
            target = work / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content, encoding="utf-8")
        _git("add", "-A", cwd=work)
        _git("commit", "-m", "initial", cwd=work)
        # Push current HEAD as master regardless of the local default branch name
        _git("push", "origin", "HEAD:master", cwd=work)


def _commit_count(bare: Path) -> int:
    """Return number of commits on master in a bare repo."""
    result = subprocess.run(
        ["git", "rev-list", "--count", "master"],
        cwd=str(bare),
        check=True,
        capture_output=True,
        text=True,
    )
    return int(result.stdout.strip())


def _tag_list(bare: Path) -> list:
    result = subprocess.run(
        ["git", "tag"],
        cwd=str(bare),
        check=True,
        capture_output=True,
        text=True,
    )
    return [t for t in result.stdout.strip().splitlines() if t]


# ── Test cases ────────────────────────────────────────────────────────────────

class TestRunGit(unittest.TestCase):
    def test_success(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = run_git(["init", tmp])
            self.assertEqual(result.returncode, 0)

    def test_failure_raises_git_error(self):
        with self.assertRaises(GitError):
            run_git(["rev-parse", "HEAD"], cwd="/tmp")


class TestAssertMirrorIdentity(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.mkdtemp(prefix="identity-test-")
        self.tmp = Path(self._tmp)

    def tearDown(self):
        shutil.rmtree(self._tmp, ignore_errors=True)

    def _make_clone_with_remote(self, remote_url: str) -> Path:
        bare = self.tmp / "origin.git"
        bare.mkdir()
        _git("init", "--bare", str(bare), cwd=self.tmp)
        _seed_repo(bare, {"main.tf": "# placeholder"})
        clone = self.tmp / "clone"
        _git("clone", str(bare), str(clone), cwd=self.tmp)
        # Override the remote URL to the desired value
        _git("remote", "set-url", "origin", remote_url, cwd=clone)
        return clone

    def test_matching_module_name(self):
        clone = self._make_clone_with_remote(
            "https://github.com/c0x12c/terraform-aws-s3.git"
        )
        # Should not raise
        assert_mirror_identity(clone, "terraform-aws-s3")

    def test_matching_without_dot_git(self):
        clone = self._make_clone_with_remote(
            "https://github.com/c0x12c/terraform-aws-s3"
        )
        assert_mirror_identity(clone, "terraform-aws-s3")

    def test_mismatch_raises_identity_error(self):
        clone = self._make_clone_with_remote(
            "https://github.com/c0x12c/terraform-aws-rds.git"
        )
        with self.assertRaises(IdentityError):
            assert_mirror_identity(clone, "terraform-aws-s3")


class TestComputeRemovals(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.mkdtemp(prefix="removals-test-")
        self.tmp = Path(self._tmp)

    def tearDown(self):
        shutil.rmtree(self._tmp, ignore_errors=True)

    def test_no_github_dir(self):
        self.assertEqual(compute_removals(self.tmp), [])

    def test_github_dir_present(self):
        gh = self.tmp / ".github" / "workflows"
        gh.mkdir(parents=True)
        (gh / "ci.yml").write_text("name: CI", encoding="utf-8")
        (self.tmp / ".github" / "dependabot.yml").write_text(
            "version: 2", encoding="utf-8"
        )
        removals = compute_removals(self.tmp)
        self.assertIn(".github", removals)
        self.assertTrue(any("ci.yml" in r for r in removals))
        self.assertTrue(any("dependabot.yml" in r for r in removals))


class TestFreezeModule(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.mkdtemp(prefix="freeze-test-")
        self.tmp = Path(self._tmp)
        self.module = "terraform-aws-s3"

    def tearDown(self):
        shutil.rmtree(self._tmp, ignore_errors=True)

    def _make_mirror(self, with_github: bool = True) -> Path:
        bare = _make_bare_repo(self.tmp, self.module)
        files = {"main.tf": "# module code"}
        if with_github:
            files[".github/workflows/ci.yml"] = "name: CI"
            files[".github/dependabot.yml"] = "version: 2"
        _seed_repo(bare, files)
        return bare

    def _remote(self, bare: Path) -> str:
        # Uses file:// so local clone works; remote ends with /<module>.git
        return "file://%s" % str(bare)

    def test_freeze_removes_github_and_commits(self):
        bare = self._make_mirror(with_github=True)
        before = _commit_count(bare)
        result = freeze_module(self.module, self._remote(bare), dry_run=False)
        self.assertEqual(result["status"], "frozen")
        self.assertIn(".github", result["removals"])
        after = _commit_count(bare)
        self.assertEqual(after, before + 1)

        # Verify .github is gone from master
        listing = subprocess.run(
            ["git", "ls-tree", "-r", "--name-only", "master"],
            cwd=str(bare),
            check=True,
            capture_output=True,
            text=True,
        ).stdout
        self.assertNotIn(".github", listing)
        self.assertIn("main.tf", listing)

    def test_commit_message(self):
        bare = self._make_mirror(with_github=True)
        freeze_module(self.module, self._remote(bare), dry_run=False)
        msg = subprocess.run(
            ["git", "log", "-1", "--format=%s", "master"],
            cwd=str(bare),
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()
        self.assertIn("freeze mirror", msg)

    def test_already_frozen_no_new_commit(self):
        bare = self._make_mirror(with_github=False)
        before = _commit_count(bare)
        result = freeze_module(self.module, self._remote(bare), dry_run=False)
        self.assertEqual(result["status"], "already-frozen")
        self.assertEqual(_commit_count(bare), before)

    def test_dry_run_no_mutation(self):
        bare = self._make_mirror(with_github=True)
        before = _commit_count(bare)
        result = freeze_module(self.module, self._remote(bare), dry_run=True)
        self.assertEqual(result["status"], "dry-run")
        self.assertIn(".github", result["removals"])
        self.assertEqual(_commit_count(bare), before)

    def test_tags_untouched_after_freeze(self):
        bare = self._make_mirror(with_github=True)
        # Add a tag to the bare repo before freezing
        with tempfile.TemporaryDirectory(prefix="tag-seed-") as tmp:
            work = Path(tmp) / "work"
            subprocess.run(
                ["git", "clone", str(bare), str(work)],
                check=True, capture_output=True,
            )
            subprocess.run(
                ["git", "checkout", "master"],
                cwd=str(work), check=True, capture_output=True,
            )
            subprocess.run(
                ["git", "tag", "v1.0.0"],
                cwd=str(work), check=True, capture_output=True,
            )
            subprocess.run(
                ["git", "push", "origin", "v1.0.0"],
                cwd=str(work), check=True, capture_output=True,
            )
        tags_before = _tag_list(bare)
        self.assertIn("v1.0.0", tags_before)
        freeze_module(self.module, self._remote(bare), dry_run=False)
        tags_after = _tag_list(bare)
        self.assertEqual(tags_before, tags_after)

    def test_identity_mismatch_returns_failed(self):
        """Wrong module name → FAILED; does not raise."""
        bare = self._make_mirror(with_github=True)
        # Use a remote URL that clearly does NOT end with our module name
        remote = "file://%s" % str(bare)
        result = freeze_module("terraform-aws-rds", remote, dry_run=False)
        self.assertTrue(result["status"].startswith("FAILED"))
        self.assertIn("identity", result["status"])


class TestMain(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.mkdtemp(prefix="main-test-")
        self.tmp = Path(self._tmp)

    def tearDown(self):
        shutil.rmtree(self._tmp, ignore_errors=True)

    def _make_module_mirror(self, name: str, with_github: bool = True) -> Path:
        bare = _make_bare_repo(self.tmp, name)
        files = {"main.tf": "# %s" % name}
        if with_github:
            files[".github/workflows/ci.yml"] = "name: CI"
        _seed_repo(bare, files)
        return bare

    def test_main_freeze_single_module(self):
        module = "terraform-aws-s3"
        bare = self._make_module_mirror(module, with_github=True)
        remote_base = "file://%s" % str(self.tmp)
        report = str(self.tmp / "report.json")
        rc = main([
            "--modules", module,
            "--remote-base", remote_base,
            "--report", report,
            "--monorepo-root", str(self.tmp),
        ])
        self.assertEqual(rc, 0)
        with open(report) as fh:
            data = json.load(fh)
        self.assertEqual(len(data), 1)
        self.assertEqual(data[0]["status"], "frozen")

    def test_main_already_frozen_zero_exit(self):
        module = "terraform-aws-s3"
        self._make_module_mirror(module, with_github=False)
        remote_base = "file://%s" % str(self.tmp)
        report = str(self.tmp / "report.json")
        rc = main([
            "--modules", module,
            "--remote-base", remote_base,
            "--report", report,
            "--monorepo-root", str(self.tmp),
        ])
        self.assertEqual(rc, 0)

    def test_main_continues_after_one_failure(self):
        """Identity mismatch on one module → FAILED; others still processed; exit non-zero."""
        good_module = "terraform-aws-s3"
        bad_module = "terraform-aws-rds"
        # Only create a mirror for terraform-aws-s3 bare repo but labelled as terraform-aws-rds
        # so that when we try to freeze terraform-aws-rds, the identity check fails
        _make_bare_repo(self.tmp, "terraform-aws-rds")  # empty; clone will fail
        self._make_module_mirror(good_module, with_github=True)
        remote_base = "file://%s" % str(self.tmp)
        report = str(self.tmp / "report.json")
        rc = main([
            "--modules", "%s,%s" % (bad_module, good_module),
            "--remote-base", remote_base,
            "--report", report,
            "--monorepo-root", str(self.tmp),
        ])
        self.assertNotEqual(rc, 0)
        with open(report) as fh:
            data = json.load(fh)
        statuses = {r["module"]: r["status"] for r in data}
        self.assertTrue(statuses[bad_module].startswith("FAILED"))
        self.assertEqual(statuses[good_module], "frozen")

    def test_main_dry_run(self):
        module = "terraform-aws-s3"
        bare = self._make_module_mirror(module, with_github=True)
        before = _commit_count(bare)
        remote_base = "file://%s" % str(self.tmp)
        report = str(self.tmp / "report.json")
        rc = main([
            "--modules", module,
            "--remote-base", remote_base,
            "--report", report,
            "--dry-run",
            "--monorepo-root", str(self.tmp),
        ])
        self.assertEqual(rc, 0)
        self.assertEqual(_commit_count(bare), before)
        with open(report) as fh:
            data = json.load(fh)
        self.assertEqual(data[0]["status"], "dry-run")


if __name__ == "__main__":
    unittest.main()
