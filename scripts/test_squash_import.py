import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT_PATH = Path(__file__).with_name("squash_import.py")
GIT_ENV = {
    "GIT_AUTHOR_NAME": "Test User",
    "GIT_AUTHOR_EMAIL": "test@example.com",
    "GIT_COMMITTER_NAME": "Test User",
    "GIT_COMMITTER_EMAIL": "test@example.com",
}


def run(cmd, cwd, check=True, env=None):
    full_env = os.environ.copy()
    full_env.update(GIT_ENV)
    if env:
        full_env.update(env)
    completed = subprocess.run(
        cmd,
        cwd=str(cwd),
        check=False,
        capture_output=True,
        text=True,
        env=full_env,
    )
    if check and completed.returncode != 0:
        raise AssertionError(
            "command failed: %s\nstdout=%s\nstderr=%s"
            % (" ".join(cmd), completed.stdout, completed.stderr)
        )
    return completed


def git(cwd, *args, check=True, env=None):
    return run(["git"] + list(args), cwd=cwd, check=check, env=env)


class SquashImportCliTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory(prefix="squash-import-tests-")
        self.root = Path(self.temp_dir.name)
        self.remotes = self.root / "remotes"
        self.seeds = self.root / "seeds"
        self.monorepo = self.root / "monorepo"
        self.remotes.mkdir()
        self.seeds.mkdir()
        git(self.root, "init", str(self.monorepo))
        (self.monorepo / "README.md").write_text("fixture monorepo\n", encoding="utf-8")
        git(self.monorepo, "add", "README.md")
        git(self.monorepo, "commit", "-m", "initial monorepo")
        self.module_a = "terraform-aws-network"
        self.module_b = "terraform-google-project"
        self.remote_a, self.seed_a = self.init_module_remote(self.module_a, with_tag=True)
        self.remote_b, self.seed_b = self.init_module_remote(self.module_b, with_tag=False)
        self.add_submodule(self.module_a, self.remote_a)
        self.add_submodule(self.module_b, self.remote_b)
        self.recorded_a = self.rev_parse(self.monorepo / self.module_a, "HEAD")
        self.recorded_b = self.rev_parse(self.monorepo / self.module_b, "HEAD")
        self.advance_remote(self.seed_a, self.module_a, "delta-a.txt", "ahead from gitlink\n")
        self.head_a = self.rev_parse(self.seed_a, "HEAD")
        self.head_b = self.rev_parse(self.seed_b, "HEAD")
        manifest = {self.module_a: "1.0.0"}
        (self.monorepo / ".module-versions.json").write_text(
            json.dumps(manifest),
            encoding="utf-8",
        )
        git(self.monorepo, "add", ".")
        git(self.monorepo, "commit", "-m", "fixture monorepo")
        self.script_env = {"SQUASH_IMPORT_GIT_FLAGS": "-c protocol.file.allow=always"}

    def tearDown(self):
        self.temp_dir.cleanup()

    def init_module_remote(self, module_name, with_tag):
        bare = self.remotes / ("%s.git" % module_name)
        seed = self.seeds / module_name
        git(self.root, "init", "--bare", str(bare))
        git(self.root, "init", str(seed))
        (seed / "README.md").write_text("%s\n" % module_name, encoding="utf-8")
        github_dir = seed / ".github" / "workflows"
        github_dir.mkdir(parents=True)
        (github_dir / "ci.yml").write_text("name: ci\n", encoding="utf-8")
        (seed / "module.txt").write_text("content for %s\n" % module_name, encoding="utf-8")
        git(seed, "add", ".")
        git(seed, "commit", "-m", "initial module")
        git(seed, "branch", "-M", "master")
        git(seed, "remote", "add", "origin", str(bare))
        git(seed, "push", "-u", "origin", "master")
        if with_tag:
            git(seed, "tag", "v1.0.0")
            git(seed, "push", "origin", "v1.0.0")
        return bare, seed

    def add_submodule(self, module_name, remote_path):
        git(
            self.monorepo,
            "-c",
            "protocol.file.allow=always",
            "submodule",
            "add",
            "-b",
            "master",
            str(remote_path),
            module_name,
        )

    def advance_remote(self, seed, module_name, filename, content):
        (seed / filename).write_text(content, encoding="utf-8")
        git(seed, "add", filename)
        git(seed, "commit", "-m", "advance %s" % module_name)
        git(seed, "push", "origin", "master")

    def rev_parse(self, cwd, ref):
        return git(cwd, "rev-parse", ref).stdout.strip()

    def run_cli(self, extra_args=None):
        cmd = [
            sys.executable,
            str(SCRIPT_PATH),
            "--repo-root",
            str(self.monorepo),
        ]
        if extra_args:
            cmd.extend(extra_args)
        return run(cmd, cwd=self.root, check=False, env=self.script_env)

    def read_summary(self):
        return json.loads(
            (self.monorepo / ".agent" / "import-summary.json").read_text(encoding="utf-8")
        )

    def test_full_convert_of_all_modules(self):
        result = self.run_cli()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.monorepo / ".gitmodules").exists())
        self.assertFalse((self.monorepo / self.module_a / ".git").exists())
        self.assertFalse((self.monorepo / self.module_b / ".git").exists())
        self.assertFalse((self.monorepo / self.module_a / ".github").exists())
        self.assertFalse((self.monorepo / self.module_b / ".github").exists())
        self.assertTrue((self.monorepo / self.module_a / "delta-a.txt").exists())
        self.assertTrue((self.monorepo / self.module_b / "module.txt").exists())
        ls_files = git(self.monorepo, "ls-files", "--stage").stdout
        self.assertNotIn("160000", ls_files)

        summary = self.read_summary()
        by_module = {item["module"]: item for item in summary["results"]}
        self.assertEqual(by_module[self.module_a]["imported_sha"], self.head_a)
        self.assertEqual(by_module[self.module_b]["imported_sha"], self.head_b)
        self.assertEqual(by_module[self.module_a]["unreleased_delta"], "yes")
        self.assertEqual(by_module[self.module_b]["unreleased_delta"], "no")
        self.assertEqual(by_module[self.module_a]["tags"], "yes")
        self.assertEqual(by_module[self.module_b]["tags"], "none")
        self.assertEqual(by_module[self.module_a]["manifest"], "yes")
        self.assertEqual(by_module[self.module_b]["manifest"], "MISSING")
        self.assertIn("missing from manifest", result.stdout)

    def test_idempotent_rerun_skips_already_converted_modules(self):
        first = self.run_cli(["--modules", "%s,%s" % (self.module_a, self.module_b)])
        self.assertEqual(first.returncode, 0, first.stderr)

        second = self.run_cli(["--modules", "%s,%s" % (self.module_a, self.module_b)])
        self.assertEqual(second.returncode, 0, second.stderr)
        summary = self.read_summary()
        statuses = {item["module"]: item["status"] for item in summary["results"]}
        self.assertEqual(statuses[self.module_a], "skipped")
        self.assertEqual(statuses[self.module_b], "skipped")
        self.assertIn("already converted", second.stdout)

    def test_dry_run_mutates_nothing(self):
        before_status = git(self.monorepo, "status", "--short").stdout
        before_gitmodules = (self.monorepo / ".gitmodules").read_text(encoding="utf-8")
        result = self.run_cli(["--dry-run"])
        after_status = git(self.monorepo, "status", "--short").stdout
        after_gitmodules = (self.monorepo / ".gitmodules").read_text(encoding="utf-8")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before_status, "")
        self.assertEqual(after_status, "?? .agent/\n")
        self.assertEqual(before_gitmodules, after_gitmodules)
        self.assertTrue((self.monorepo / self.module_a / ".git").exists())
        self.assertTrue((self.monorepo / self.module_b / ".git").exists())
        summary = self.read_summary()
        self.assertTrue(all(item["status"] == "planned" for item in summary["results"]))

    def test_modules_subset_leaves_other_submodule_intact(self):
        result = self.run_cli(["--modules", self.module_a])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.monorepo / ".gitmodules").exists())
        gitmodules = (self.monorepo / ".gitmodules").read_text(encoding="utf-8")
        self.assertNotIn(self.module_a, gitmodules)
        self.assertIn(self.module_b, gitmodules)
        ls_files = git(self.monorepo, "ls-files", "--stage").stdout
        self.assertIn("160000 %s 0\t%s" % (self.recorded_b, self.module_b), ls_files)
        self.assertNotIn("160000 %s 0\t%s" % (self.recorded_a, self.module_a), ls_files)
        self.assertFalse((self.monorepo / self.module_a / ".github").exists())
        self.assertTrue((self.monorepo / self.module_b / ".github").exists())


if __name__ == "__main__":
    unittest.main()
