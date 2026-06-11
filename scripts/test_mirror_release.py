import json
import io
import os
import subprocess
import sys
import tarfile
import tempfile
import textwrap
import unittest
from types import SimpleNamespace
from unittest import mock
from pathlib import Path

# Ensure the scripts/ directory is on sys.path so `mirror_release` can be imported
# whether this module is loaded as `scripts.test_mirror_release` or run directly.
sys.path.insert(0, str(Path(__file__).parent))

import mirror_release
from mirror_release import (
    EXIT_IDENTITY,
    EXIT_LEFTOVER_RELATIVE,
    EXIT_MANIFEST,
    EXIT_MAPPING,
    EXIT_TAG_CONFLICT,
    EXIT_VALIDATE,
    README_BANNER_FIRST_LINE,
    module_to_registry,
    rewrite_tf_text,
    upload_to_r2,
    _is_examples_path,
)


SCRIPT_PATH = Path(__file__).with_name("mirror_release.py")
GIT_ENV = {
    "GIT_AUTHOR_NAME": "Test User",
    "GIT_AUTHOR_EMAIL": "test@example.com",
    "GIT_COMMITTER_NAME": "Test User",
    "GIT_COMMITTER_EMAIL": "test@example.com",
}


def run(cmd, cwd, check=True, env=None):
    full_env = os.environ.copy()
    if env:
        full_env.update(env)
    completed = subprocess.run(
        cmd,
        cwd=str(cwd),
        check=False,
        text=True,
        capture_output=True,
        env=full_env,
    )
    if check and completed.returncode != 0:
        raise AssertionError(
            "command failed: %s\nstdout=%s\nstderr=%s"
            % (" ".join(cmd), completed.stdout, completed.stderr)
        )
    return completed


def git(cwd, *args, check=True):
    return run(["git"] + list(args), cwd=cwd, check=check, env=GIT_ENV)


class MirrorReleasePureTests(unittest.TestCase):
    def test_module_mapping_happy(self):
        mapping = module_to_registry("terraform-aws-msk-kafka-cluster", "c0x12c")
        self.assertEqual(mapping.registry_source, "c0x12c/msk-kafka-cluster/aws")

    def test_module_mapping_malformed(self):
        with self.assertRaisesRegex(Exception, "mapping"):
            module_to_registry("terraformawsbad", "c0x12c")

    def test_rewrite_happy_preserves_other_content(self):
        original = (
            'module "sibling" {\n'
            '  source = "../terraform-aws-network"\n'
            '}\n'
            '\n'
            'module "registry" {\n'
            '  source = "c0x12c/rds/aws"\n'
            '}\n'
            'locals {\n'
            '  note = "keep me"\n'
            '}\n'
        )
        manifest = {"terraform-aws-network": "2.3.4"}
        rewritten = rewrite_tf_text(original, manifest, "c0x12c")
        self.assertIn('  source = "c0x12c/network/aws"\n', rewritten)
        self.assertIn('  version = "2.3.4"\n', rewritten)
        self.assertIn('  source = "c0x12c/rds/aws"\n', rewritten)
        self.assertIn('  note = "keep me"\n', rewritten)

    def test_rewrite_missing_sibling_from_manifest_fails(self):
        with self.assertRaisesRegex(Exception, "manifest-missing"):
            rewrite_tf_text(
                'module "sibling" {\n  source = "../terraform-aws-network"\n}\n',
                {},
                "c0x12c",
            )

    def test_rewrite_leftover_relative_source_fails(self):
        # Parent-escaping non-sibling source: cannot resolve on the mirror.
        with self.assertRaisesRegex(Exception, "leftover-relative"):
            rewrite_tf_text(
                'module "shared" {\n  source = "../common/thing"\n}\n',
                {},
                "c0x12c",
            )

    def test_rewrite_intra_module_local_source_allowed(self):
        # "./<subdir>" stays inside the module folder and works on the mirror
        # (e.g. terraform-aws-rds uses source = "./db_instance").
        text = 'module "local" {\n  source = "./db_instance"\n}\n'
        result = rewrite_tf_text(text, {}, "c0x12c")
        self.assertEqual(result, text)

    def test_rewrite_examples_dir_returns_verbatim(self):
        # A relative source inside examples/ must NOT trigger leftover-relative or be rewritten.
        text = 'module "self" {\n  source = "../../"\n}\n'
        result = rewrite_tf_text(text, {}, "c0x12c", rel_path="examples/complete/main.tf")
        self.assertEqual(result, text)

    def test_rewrite_test_dir_returns_verbatim(self):
        text = 'module "self" {\n  source = "../../"\n}\n'
        result = rewrite_tf_text(text, {}, "c0x12c", rel_path="test/main.tf")
        self.assertEqual(result, text)

    def test_rewrite_tests_dir_returns_verbatim(self):
        text = 'module "self" {\n  source = "../../"\n}\n'
        result = rewrite_tf_text(text, {}, "c0x12c", rel_path="tests/main.tf")
        self.assertEqual(result, text)

    def test_is_examples_path(self):
        self.assertTrue(_is_examples_path("examples/complete/main.tf"))
        self.assertTrue(_is_examples_path("test/main.tf"))
        self.assertTrue(_is_examples_path("tests/e2e/main.tf"))
        self.assertFalse(_is_examples_path("main.tf"))
        self.assertFalse(_is_examples_path("modules/examples/main.tf"))
        self.assertFalse(_is_examples_path(""))

    def test_rewrite_relative_outside_examples_still_fails(self):
        # A parent-escaping source at the top level (not under examples/test/tests) must still fail.
        with self.assertRaisesRegex(Exception, "leftover-relative"):
            rewrite_tf_text(
                'module "shared" {\n  source = "../common/thing"\n}\n',
                {},
                "c0x12c",
                rel_path="main.tf",
            )


class MirrorReleaseCliTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory(prefix="mirror-release-tests-")
        self.root = Path(self.temp_dir.name)
        self.monorepo = self.root / "monorepo"
        self.monorepo.mkdir()
        self.module = "terraform-aws-rds"
        self.version = "v1.2.0"
        self.manifest_path = self.monorepo / ".module-versions.json"

    def tearDown(self):
        self.temp_dir.cleanup()

    def write_fixture_module(self, module_body=None, readme_body="module readme\n"):
        module_dir = self.monorepo / self.module
        module_dir.mkdir(parents=True, exist_ok=True)
        (self.monorepo / "terraform-aws-network").mkdir(exist_ok=True)
        default_body = textwrap.dedent(
            """
            module "sibling" {
              source = "../terraform-aws-network"
            }

            module "registry" {
              source = "c0x12c/external/aws"
            }

            locals {
              marker = "fixture"
            }
            """
        ).lstrip()
        (module_dir / "main.tf").write_text(module_body or default_body, encoding="utf-8")
        if readme_body is not None:
            (module_dir / "README.md").write_text(readme_body, encoding="utf-8")
        (module_dir / "notes.txt").write_text("keep bytes\n", encoding="utf-8")
        (module_dir / ".terraform.lock.hcl").write_text("ignored\n", encoding="utf-8")
        terraform_dir = module_dir / ".terraform"
        terraform_dir.mkdir(exist_ok=True)
        (terraform_dir / "junk").write_text("ignored\n", encoding="utf-8")
        manifest = {
            self.module: "1.2.0",
            "terraform-aws-network": "9.8.7",
        }
        self.manifest_path.write_text(json.dumps(manifest), encoding="utf-8")

    def init_remote(self, remote_name=None):
        name = remote_name or self.module
        bare = self.root / ("%s.git" % name)
        work = self.root / ("%s-seed" % name)
        git(self.root, "init", "--bare", str(bare))
        git(self.root, "init", str(work))
        (work / "README.md").write_text("seed\n", encoding="utf-8")
        git(work, "add", "README.md")
        git(work, "commit", "-m", "seed")
        git(work, "branch", "-M", "master")
        git(work, "remote", "add", "origin", str(bare))
        git(work, "push", "-u", "origin", "master")
        return bare

    def run_cli(self, remote, validate_cmd="true", extra_args=None):
        cmd = [
            sys.executable,
            str(SCRIPT_PATH),
            "--module",
            self.module,
            "--version",
            self.version,
            "--mirror-remote",
            str(remote),
            "--monorepo-root",
            str(self.monorepo),
            "--validate-cmd",
            validate_cmd,
            "--org",
            "c0x12c",
        ]
        if extra_args:
            cmd.extend(extra_args)
        return run(cmd, cwd=self.root, check=False)

    def clone_remote_for_assertions(self):
        checkout = self.root / "assert"
        git(self.root, "clone", "--branch", "master", str(self.remote), str(checkout))
        return checkout

    def test_identity_mismatch_fails(self):
        self.write_fixture_module()
        wrong_remote = self.init_remote(remote_name="terraform-aws-other")
        result = self.run_cli(wrong_remote)
        self.assertEqual(result.returncode, EXIT_IDENTITY)
        self.assertIn("identity:", result.stderr)

    def test_validate_fail_does_not_push_commit_or_tag(self):
        self.write_fixture_module()
        self.remote = self.init_remote()
        before_head = git(self.root, "ls-remote", str(self.remote), "refs/heads/master").stdout
        result = self.run_cli(self.remote, validate_cmd="false")
        after_head = git(self.root, "ls-remote", str(self.remote), "refs/heads/master").stdout
        tags = git(self.root, "ls-remote", "--tags", str(self.remote)).stdout
        self.assertEqual(result.returncode, EXIT_VALIDATE)
        self.assertEqual(before_head, after_head)
        self.assertNotIn(self.version, tags)

    def test_full_happy_path_commits_and_tags_expected_tree(self):
        self.write_fixture_module()
        self.remote = self.init_remote()
        result = self.run_cli(self.remote)
        self.assertEqual(result.returncode, 0, result.stderr)
        checkout = self.clone_remote_for_assertions()
        head_message = git(checkout, "log", "-1", "--pretty=%s").stdout.strip()
        tag_message = git(checkout, "tag", "--list", self.version).stdout.strip()
        rewritten = (checkout / "main.tf").read_text(encoding="utf-8")
        self.assertEqual(
            head_message,
            "chore: mirror terraform-aws-rds v1.2.0 from monorepo",
        )
        self.assertEqual(tag_message, self.version)
        self.assertIn('source = "c0x12c/network/aws"', rewritten)
        self.assertIn('version = "9.8.7"', rewritten)
        self.assertIn('source = "c0x12c/external/aws"', rewritten)
        readme = (checkout / "README.md").read_text(encoding="utf-8")
        self.assertTrue(readme.startswith(README_BANNER_FIRST_LINE + "\n"))
        self.assertIn(
            "tree/master/terraform-aws-rds).\n"
            "> Develop and open PRs there — changes pushed here are overwritten on the next release.\n\n"
            "module readme\n",
            readme,
        )
        self.assertTrue((checkout / "notes.txt").exists())
        self.assertFalse((checkout / ".terraform.lock.hcl").exists())
        self.assertFalse((checkout / ".terraform").exists())

    def test_idempotent_rerun_exits_zero_without_new_commit(self):
        self.write_fixture_module()
        self.remote = self.init_remote()
        first = self.run_cli(self.remote)
        self.assertEqual(first.returncode, 0, first.stderr)
        before = git(self.root, "ls-remote", str(self.remote), "refs/heads/master").stdout
        second = self.run_cli(self.remote)
        after = git(self.root, "ls-remote", str(self.remote), "refs/heads/master").stdout
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertIn("already mirrored", second.stdout)
        self.assertEqual(before, after)
        checkout = self.clone_remote_for_assertions()
        readme = (checkout / "README.md").read_text(encoding="utf-8")
        self.assertEqual(readme.count(README_BANNER_FIRST_LINE), 1)

    def test_missing_readme_gets_created_with_banner(self):
        self.write_fixture_module(readme_body=None)
        self.remote = self.init_remote()
        result = self.run_cli(self.remote)
        self.assertEqual(result.returncode, 0, result.stderr)
        checkout = self.clone_remote_for_assertions()
        readme = (checkout / "README.md").read_text(encoding="utf-8")
        self.assertEqual(
            readme,
            "> [!IMPORTANT]\n"
            "> This repository is a **read-only mirror** generated from\n"
            "> [`c0x12c/terraform-modules`](https://github.com/c0x12c/terraform-modules/tree/master/terraform-aws-rds).\n"
            "> Develop and open PRs there — changes pushed here are overwritten on the next release.\n\n",
        )

    def test_generated_terraform_artifacts_are_cleaned_before_snapshot_and_commit(self):
        self.write_fixture_module()
        self.remote = self.init_remote()
        validate_cmd = "mkdir -p .terraform/providers && touch .terraform/providers/x .terraform.lock.hcl"
        first = self.run_cli(self.remote, validate_cmd=validate_cmd)
        self.assertEqual(first.returncode, 0, first.stderr)

        checkout = self.clone_remote_for_assertions()
        tracked_files = set(git(checkout, "ls-tree", "-r", "--name-only", "HEAD").stdout.splitlines())
        self.assertNotIn(".terraform.lock.hcl", tracked_files)
        self.assertFalse(any(path.startswith(".terraform/") for path in tracked_files))

        before = git(self.root, "ls-remote", str(self.remote), "refs/heads/master").stdout
        second = self.run_cli(self.remote, validate_cmd=validate_cmd)
        after = git(self.root, "ls-remote", str(self.remote), "refs/heads/master").stdout
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertIn("already mirrored", second.stdout)
        self.assertEqual(before, after)

    def test_tag_conflict_fails_when_content_changes(self):
        self.write_fixture_module()
        self.remote = self.init_remote()
        first = self.run_cli(self.remote)
        self.assertEqual(first.returncode, 0, first.stderr)
        changed_body = textwrap.dedent(
            """
            module "sibling" {
              source = "../terraform-aws-network"
            }

            locals {
              marker = "changed"
            }
            """
        ).lstrip()
        self.write_fixture_module(module_body=changed_body)
        result = self.run_cli(self.remote)
        self.assertEqual(result.returncode, EXIT_TAG_CONFLICT)
        self.assertIn("tag-conflict:", result.stderr)

    def test_rerun_after_missing_tag_reuses_master_commit_and_pushes_tag(self):
        self.write_fixture_module()
        self.remote = self.init_remote()
        first = self.run_cli(self.remote)
        self.assertEqual(first.returncode, 0, first.stderr)
        bare_checkout = self.root / "bare-maint"
        git(self.root, "clone", str(self.remote), str(bare_checkout))
        git(bare_checkout, "push", "origin", ":refs/tags/%s" % self.version)
        before = git(self.root, "ls-remote", str(self.remote), "refs/heads/master").stdout
        rerun = self.run_cli(self.remote)
        after = git(self.root, "ls-remote", str(self.remote), "refs/heads/master").stdout
        tags = git(self.root, "ls-remote", "--tags", str(self.remote)).stdout
        self.assertEqual(rerun.returncode, 0, rerun.stderr)
        self.assertEqual(before, after)
        self.assertIn(self.version, tags)

    def test_cli_manifest_missing_is_distinct(self):
        self.write_fixture_module()
        self.remote = self.init_remote()
        self.manifest_path.unlink()
        result = self.run_cli(self.remote)
        self.assertEqual(result.returncode, EXIT_MANIFEST)
        self.assertIn("manifest-missing:", result.stderr)

    def test_cli_leftover_relative_is_distinct(self):
        relative_body = 'module "shared" {\n  source = "../common/thing"\n}\n'
        self.write_fixture_module(module_body=relative_body)
        self.remote = self.init_remote()
        result = self.run_cli(self.remote)
        self.assertEqual(result.returncode, EXIT_LEFTOVER_RELATIVE)
        self.assertIn("leftover-relative:", result.stderr)

    def test_examples_relative_source_copied_verbatim(self):
        """examples/complete/main.tf with source = "../../" must copy byte-identical, no error."""
        self.write_fixture_module()
        examples_dir = self.monorepo / self.module / "examples" / "complete"
        examples_dir.mkdir(parents=True)
        examples_body = 'module "self" {\n  source = "../../"\n}\n'
        (examples_dir / "main.tf").write_text(examples_body, encoding="utf-8")
        self.remote = self.init_remote()
        result = self.run_cli(self.remote)
        self.assertEqual(result.returncode, 0, result.stderr)
        checkout = self.clone_remote_for_assertions()
        mirrored = (checkout / "examples" / "complete" / "main.tf").read_text(encoding="utf-8")
        self.assertEqual(mirrored, examples_body)

    def test_cli_mapping_error_is_distinct(self):
        self.module = "bad-module"
        module_dir = self.monorepo / self.module
        module_dir.mkdir(parents=True, exist_ok=True)
        (module_dir / "main.tf").write_text('output "x" { value = 1 }\n', encoding="utf-8")
        self.manifest_path.write_text(json.dumps({self.module: "1.2.0"}), encoding="utf-8")
        self.remote = self.init_remote(remote_name=self.module)
        result = self.run_cli(self.remote)
        self.assertEqual(result.returncode, EXIT_MAPPING)
        self.assertIn("mapping:", result.stderr)


class _FakeNoSuchKey(Exception):
    pass


class _FakeS3Client:
    def __init__(self, initial_objects=None):
        self.objects = dict(initial_objects or {})
        self.put_calls = []
        self.get_calls = []
        self.exceptions = SimpleNamespace(NoSuchKey=_FakeNoSuchKey)

    def put_object(self, Bucket, Key, Body, ContentType):
        if hasattr(Body, "read"):
            Body = Body.read()
        if isinstance(Body, str):
            Body = Body.encode("utf-8")
        self.put_calls.append(
            {
                "Bucket": Bucket,
                "Key": Key,
                "Body": Body,
                "ContentType": ContentType,
            }
        )
        self.objects[Key] = Body

    def get_object(self, Bucket, Key):
        self.get_calls.append({"Bucket": Bucket, "Key": Key})
        if Key not in self.objects:
            raise self.exceptions.NoSuchKey()
        return {"Body": io.BytesIO(self.objects[Key])}


class _FakeBoto3Module:
    def __init__(self, client):
        self._client = client
        self.calls = []

    def client(self, service_name, endpoint_url=None):
        self.calls.append((service_name, endpoint_url))
        return self._client


class MirrorReleaseR2Tests(unittest.TestCase):
    def test_main_noops_when_r2_bucket_absent(self):
        with tempfile.TemporaryDirectory(prefix="mirror-r2-main-") as temp_dir:
            root = Path(temp_dir)
            module_dir = (root / "terraform-aws-rds").resolve()
            module_dir.mkdir()
            manifest_path = root / ".module-versions.json"
            manifest_path.write_text(
                json.dumps(
                    {
                        "terraform-aws-rds": "1.2.0",
                        "terraform-aws-network": "9.8.7",
                    }
                ),
                encoding="utf-8",
            )
            remote = "https://example.invalid/c0x12c/terraform-aws-rds.git"
            clone_dir = root / "mirror"
            clone_dir.mkdir()
            upload_calls = []

            def fake_upload(*args):
                upload_calls.append(args)

            with mock.patch.object(mirror_release, "clone_mirror") as clone_mirror, mock.patch.object(
                mirror_release, "assert_mirror_identity"
            ) as assert_identity, mock.patch.object(
                mirror_release, "copy_module_contents"
            ) as copy_contents, mock.patch.object(
                mirror_release, "rewrite_worktree_tf_files"
            ) as rewrite_tf_files, mock.patch.object(
                mirror_release, "apply_readme_banner"
            ) as apply_readme_banner, mock.patch.object(
                mirror_release, "run_validation"
            ) as run_validation, mock.patch.object(
                mirror_release, "remove_generated_terraform_artifacts"
            ) as remove_artifacts, mock.patch.object(
                mirror_release, "git_ref_exists", return_value=False
            ) as git_ref_exists, mock.patch.object(
                mirror_release, "commit_changes", return_value=True
            ) as commit_changes, mock.patch.object(
                mirror_release, "push_master"
            ) as push_master, mock.patch.object(
                mirror_release, "ensure_tag"
            ) as ensure_tag, mock.patch.object(
                mirror_release.tempfile, "TemporaryDirectory"
            ) as tempdir, mock.patch.object(
                mirror_release, "upload_to_r2", side_effect=fake_upload
            ) as upload_to_r2_mock:
                tempdir.return_value.__enter__.return_value = temp_dir
                tempdir.return_value.__exit__.return_value = False
                result = mirror_release.main(
                    [
                        "--module",
                        "terraform-aws-rds",
                        "--version",
                        "v1.2.0",
                        "--mirror-remote",
                        remote,
                        "--monorepo-root",
                        str(root),
                        "--manifest",
                        str(manifest_path),
                        "--validate-cmd",
                        "true",
                        "--org",
                        "c0x12c",
                    ]
                )

        self.assertEqual(result, 0)
        clone_mirror.assert_called_once_with(remote, clone_dir)
        assert_identity.assert_called_once_with(clone_dir, "terraform-aws-rds")
        copy_contents.assert_called_once_with(module_dir, clone_dir)
        rewrite_tf_files.assert_called_once()
        apply_readme_banner.assert_called_once_with(clone_dir, "terraform-aws-rds")
        run_validation.assert_called_once_with(clone_dir, "true")
        remove_artifacts.assert_called_once_with(clone_dir)
        git_ref_exists.assert_called_once_with(clone_dir, "refs/tags/v1.2.0")
        commit_changes.assert_called_once_with(clone_dir, "terraform-aws-rds", "v1.2.0")
        push_master.assert_called_once_with(clone_dir)
        ensure_tag.assert_called_once_with(clone_dir, "v1.2.0")
        upload_to_r2_mock.assert_not_called()
        self.assertEqual(upload_calls, [])

    def test_upload_to_r2_tarball_shape(self):
        with tempfile.TemporaryDirectory(prefix="mirror-r2-tar-") as temp_dir:
            clone_dir = Path(temp_dir)
            (clone_dir / "main.tf").write_text(
                'module "network" {\n  source = "c0x12c/network/aws"\n}\n',
                encoding="utf-8",
            )
            (clone_dir / "versions.tf").write_text('terraform {}\n', encoding="utf-8")
            git_dir = clone_dir / ".git"
            git_dir.mkdir()
            (git_dir / "config").write_text("[core]\n", encoding="utf-8")
            fake_client = _FakeS3Client()
            fake_boto3 = _FakeBoto3Module(fake_client)

            with mock.patch.dict(sys.modules, {"boto3": fake_boto3}), mock.patch.dict(
                os.environ, {"R2_ENDPOINT": "https://r2.example.invalid"}, clear=False
            ):
                upload_to_r2(
                    clone_dir,
                    "terraform-aws-rds",
                    "v1.2.0",
                    "mirror-bucket",
                    "c0x12c",
                )

        self.assertEqual(fake_boto3.calls, [("s3", "https://r2.example.invalid")])
        tarball = fake_client.objects["modules/c0x12c/rds/aws/1.2.0.tar.gz"]
        with tarfile.open(fileobj=io.BytesIO(tarball), mode="r:gz") as archive:
            names = archive.getnames()
            self.assertIn("main.tf", names)
            self.assertIn("versions.tf", names)
            self.assertFalse(any(name.startswith(".git") for name in names))
            main_tf = archive.extractfile("main.tf").read().decode("utf-8")
        self.assertNotIn("../", main_tf)

    def test_upload_to_r2_index_json_merge_and_dedupe(self):
        fake_client = _FakeS3Client(
            {
                "index.json": (
                    json.dumps({"c0x12c/foo/aws": ["0.1.0"]}, indent=2) + "\n"
                ).encode("utf-8")
            }
        )
        fake_boto3 = _FakeBoto3Module(fake_client)
        with tempfile.TemporaryDirectory(prefix="mirror-r2-index-") as temp_dir:
            clone_dir = Path(temp_dir)
            (clone_dir / "main.tf").write_text("terraform {}\n", encoding="utf-8")
            with mock.patch.dict(sys.modules, {"boto3": fake_boto3}), mock.patch.dict(
                os.environ, {"R2_ENDPOINT": "https://r2.example.invalid"}, clear=False
            ):
                upload_to_r2(
                    clone_dir,
                    "terraform-aws-foo",
                    "v0.2.0",
                    "mirror-bucket",
                    "c0x12c",
                )
                upload_to_r2(
                    clone_dir,
                    "terraform-aws-foo",
                    "v0.2.0",
                    "mirror-bucket",
                    "c0x12c",
                )

        index = json.loads(fake_client.objects["index.json"].decode("utf-8"))
        self.assertEqual(index["c0x12c/foo/aws"], ["0.1.0", "0.2.0"])

    def test_upload_to_r2_uses_registry_key_layout(self):
        fake_client = _FakeS3Client()
        fake_boto3 = _FakeBoto3Module(fake_client)
        with tempfile.TemporaryDirectory(prefix="mirror-r2-key-") as temp_dir:
            clone_dir = Path(temp_dir)
            (clone_dir / "main.tf").write_text("terraform {}\n", encoding="utf-8")
            with mock.patch.dict(sys.modules, {"boto3": fake_boto3}), mock.patch.dict(
                os.environ, {"R2_ENDPOINT": "https://r2.example.invalid"}, clear=False
            ):
                upload_to_r2(
                    clone_dir,
                    "terraform-aws-msk-kafka-cluster",
                    "v0.6.6",
                    "mirror-bucket",
                    "c0x12c",
                )

        tar_keys = [call["Key"] for call in fake_client.put_calls if call["Key"].endswith(".tar.gz")]
        self.assertEqual(tar_keys, ["modules/c0x12c/msk-kafka-cluster/aws/0.6.6.tar.gz"])


if __name__ == "__main__":
    unittest.main()
