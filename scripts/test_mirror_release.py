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
    EXIT_LEFTOVER_RELATIVE,
    EXIT_MANIFEST,
    EXIT_MAPPING,
    EXIT_VALIDATE,
    assemble_r2_tree,
    module_to_registry,
    rewrite_tf_text,
    upload_to_r2,
    _is_examples_path,
)


SCRIPT_PATH = Path(__file__).with_name("mirror_release.py")


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


class MirrorReleasePureTests(unittest.TestCase):
    def test_module_mapping_happy(self):
        mapping = module_to_registry("terraform-aws-msk-kafka-cluster", "c0x12c")
        self.assertEqual(mapping.registry_source, "c0x12c/msk-kafka-cluster/aws")

    def test_assemble_r2_tree_rewrites_siblings_no_git_no_banner(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            module_dir = root / "terraform-aws-rds"
            module_dir.mkdir()
            (module_dir / "main.tf").write_text(
                'module "net" {\n  source = "../terraform-aws-network"\n}\n',
                encoding="utf-8",
            )
            (module_dir / "README.md").write_text("rds module\n", encoding="utf-8")
            dest = root / "out"
            dest.mkdir()
            manifest = {"terraform-aws-rds": "1.2.0", "terraform-aws-network": "9.8.7"}
            # validate_cmd="true" → no-op validation, no terraform needed
            assemble_r2_tree(module_dir, dest, manifest, "c0x12c", "true")

            main_tf = (dest / "main.tf").read_text(encoding="utf-8")
            self.assertIn(
                'source  = "terraform.c0x12c.com/c0x12c/network/aws"', main_tf
            )  # sibling rewritten
            self.assertIn('version = "9.8.7"', main_tf)
            self.assertNotIn("../terraform-aws-network", main_tf)  # no leftover relative
            # R2-only adds no mirror banner — README is byte-identical
            readme = (dest / "README.md").read_text(encoding="utf-8")
            self.assertEqual(readme, "rds module\n")
            # no git artifacts in the R2 tree
            self.assertFalse((dest / ".git").exists())

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
        self.assertIn(
            '  source  = "terraform.c0x12c.com/c0x12c/network/aws"\n', rewritten
        )
        self.assertIn('  version = "2.3.4"\n', rewritten)
        self.assertIn('  source = "c0x12c/rds/aws"\n', rewritten)
        self.assertIn('  note = "keep me"\n', rewritten)

    def test_rewrite_output_passes_terraform_fmt(self):
        # Regression: the source -> source+version rewrite must emit "="-aligned
        # lines, otherwise `terraform fmt -check` (part of the default validate
        # command) rejects the mirror with exit 3. See mirror_release exit 15.
        import shutil

        terraform = shutil.which("terraform")
        if not terraform:
            self.skipTest("terraform binary not available")
        original = (
            'module "sibling" {\n'
            '  source = "../terraform-aws-network"\n'
            '\n'
            '  environment = "prod"\n'
            '}\n'
        )
        manifest = {"terraform-aws-network": "2.3.4"}
        rewritten = rewrite_tf_text(original, manifest, "c0x12c")
        with tempfile.TemporaryDirectory() as tmp:
            tf_file = Path(tmp) / "main.tf"
            tf_file.write_text(rewritten, encoding="utf-8")
            result = subprocess.run(
                [terraform, "fmt", "-check", str(tf_file)],
                capture_output=True,
                text=True,
            )
        self.assertEqual(
            result.returncode,
            0,
            "terraform fmt -check rejected rewritten output:\n%s" % rewritten,
        )

    def test_assemble_realigns_neighbor_meta_arg_passes_fmt(self):
        # Regression: a `count =` above a sibling source widens the fmt
        # alignment run when version is inserted; assemble must re-fmt it.
        import shutil

        if not shutil.which("terraform"):
            self.skipTest("terraform binary not available")
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            module_dir = root / "terraform-aws-foo"
            module_dir.mkdir()
            (module_dir / "main.tf").write_text(
                'module "bar" {\n'
                '  count  = var.enabled ? 1 : 0\n'
                '  source = "../terraform-aws-baz"\n'
                '}\n',
                encoding="utf-8",
            )
            dest = root / "out"
            dest.mkdir()
            manifest = {"terraform-aws-foo": "1.0.0", "terraform-aws-baz": "2.0.0"}
            assemble_r2_tree(
                module_dir,
                dest,
                manifest,
                "c0x12c",
                "terraform fmt -check -recursive",
            )
            main_tf = (dest / "main.tf").read_text(encoding="utf-8")
            self.assertIn('terraform.c0x12c.com/c0x12c/baz/aws', main_tf)
            self.assertIn('version = "2.0.0"', main_tf)

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

    def run_cli(self, validate_cmd="true", extra_args=None):
        cmd = [
            sys.executable,
            str(SCRIPT_PATH),
            "--module",
            self.module,
            "--version",
            self.version,
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

    def test_dry_run_assembles_and_validates(self):
        self.write_fixture_module()
        result = self.run_cli(extra_args=["--dry-run"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("dry-run", result.stdout)

    def test_missing_bucket_without_dry_run_is_usage_error(self):
        self.write_fixture_module()
        result = self.run_cli()  # no --r2-bucket and no --dry-run
        self.assertEqual(result.returncode, 2)
        self.assertIn("--r2-bucket is required", result.stderr)

    def test_validate_failure_is_distinct(self):
        self.write_fixture_module()
        result = self.run_cli(validate_cmd="false", extra_args=["--dry-run"])
        self.assertEqual(result.returncode, EXIT_VALIDATE)
        self.assertIn("validate:", result.stderr)

    def test_manifest_missing_is_distinct(self):
        self.write_fixture_module()
        self.manifest_path.unlink()
        result = self.run_cli(extra_args=["--dry-run"])
        self.assertEqual(result.returncode, EXIT_MANIFEST)
        self.assertIn("manifest-missing:", result.stderr)

    def test_leftover_relative_is_distinct(self):
        relative_body = 'module "shared" {\n  source = "../common/thing"\n}\n'
        self.write_fixture_module(module_body=relative_body)
        result = self.run_cli(extra_args=["--dry-run"])
        self.assertEqual(result.returncode, EXIT_LEFTOVER_RELATIVE)
        self.assertIn("leftover-relative:", result.stderr)

    def test_examples_relative_source_does_not_error(self):
        """A "../../" source under examples/ is copied verbatim — must not trip leftover-relative."""
        self.write_fixture_module()
        examples_dir = self.monorepo / self.module / "examples" / "complete"
        examples_dir.mkdir(parents=True)
        (examples_dir / "main.tf").write_text(
            'module "self" {\n  source = "../../"\n}\n', encoding="utf-8"
        )
        result = self.run_cli(extra_args=["--dry-run"])
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_mapping_error_is_distinct(self):
        self.module = "bad-module"
        module_dir = self.monorepo / self.module
        module_dir.mkdir(parents=True, exist_ok=True)
        (module_dir / "main.tf").write_text('output "x" { value = 1 }\n', encoding="utf-8")
        self.manifest_path.write_text(json.dumps({self.module: "1.2.0"}), encoding="utf-8")
        result = self.run_cli(extra_args=["--dry-run"])
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
    def test_dry_run_does_not_upload(self):
        with tempfile.TemporaryDirectory(prefix="r2-dry-") as temp_dir:
            root = Path(temp_dir)
            module_dir = root / "terraform-aws-rds"
            module_dir.mkdir()
            (module_dir / "main.tf").write_text("terraform {}\n", encoding="utf-8")
            manifest_path = root / ".module-versions.json"
            manifest_path.write_text(
                json.dumps({"terraform-aws-rds": "1.2.0"}), encoding="utf-8"
            )
            with mock.patch.object(mirror_release, "upload_to_r2") as upload:
                result = mirror_release.main(
                    [
                        "--module", "terraform-aws-rds",
                        "--version", "v1.2.0",
                        "--monorepo-root", str(root),
                        "--manifest", str(manifest_path),
                        "--validate-cmd", "true",
                        "--dry-run",
                    ]
                )
                self.assertEqual(result, 0)
                upload.assert_not_called()

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
