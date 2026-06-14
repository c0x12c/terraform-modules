import io
import json
import os
import sys
import tarfile
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest import mock


sys.path.insert(0, str(Path(__file__).parent))

import migrate_r2_source_host
from migrate_r2_source_host import (
    REGISTRY_HOST,
    build_source_re,
    iter_published,
    migrate,
    rewrite_tarball,
    rewrite_tf_text,
)


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


def _make_tarball(members):
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode="w:gz") as archive:
        for member in members:
            tarinfo = tarfile.TarInfo(member["name"])
            tarinfo.mode = member.get("mode", 0o644)
            tarinfo.mtime = member.get("mtime", 1_700_000_000)
            tarinfo.uid = member.get("uid", 123)
            tarinfo.gid = member.get("gid", 456)
            tarinfo.type = member.get("type", tarfile.REGTYPE)
            body = member.get("body")
            if body is None:
                archive.addfile(tarinfo)
                continue
            tarinfo.size = len(body)
            archive.addfile(tarinfo, io.BytesIO(body))
    return buffer.getvalue()


def _read_tarball(blob):
    output = {}
    with tarfile.open(fileobj=io.BytesIO(blob), mode="r:gz") as archive:
        for member in archive.getmembers():
            payload = None
            fileobj = archive.extractfile(member)
            if fileobj is not None:
                payload = fileobj.read()
            output[member.name] = {"member": member, "body": payload}
    return output


class RewriteTfTextTests(unittest.TestCase):
    def setUp(self):
        self.source_re = build_source_re("c0x12c")

    def test_rewrites_bare_source(self):
        text = 'module "db" {\n  source = "c0x12c/rds/aws"\n}\n'
        rewritten, n_changed = rewrite_tf_text(text, self.source_re)
        self.assertEqual(n_changed, 1)
        self.assertIn(
            'source = "%s/c0x12c/rds/aws"' % REGISTRY_HOST,
            rewritten,
        )

    def test_rewrites_submodule_source_and_preserves_suffix(self):
        text = '  source = "c0x12c/rds/aws//modules/replica"?\r\n'
        rewritten, n_changed = rewrite_tf_text(text, self.source_re)
        self.assertEqual(n_changed, 1)
        self.assertEqual(
            rewritten,
            '  source = "%s/c0x12c/rds/aws//modules/replica"?\r\n' % REGISTRY_HOST,
        )

    def test_already_qualified_source_is_unchanged(self):
        text = '  source = "terraform.c0x12c.com/c0x12c/rds/aws"\n'
        rewritten, n_changed = rewrite_tf_text(text, self.source_re)
        self.assertEqual((rewritten, n_changed), (text, 0))

    def test_external_public_module_is_unchanged(self):
        text = '  source = "terraform-aws-modules/vpc/aws"\n'
        rewritten, n_changed = rewrite_tf_text(text, self.source_re)
        self.assertEqual((rewritten, n_changed), (text, 0))

    def test_two_segment_provider_is_unchanged(self):
        text = '  source = "hashicorp/aws"\n'
        rewritten, n_changed = rewrite_tf_text(text, self.source_re)
        self.assertEqual((rewritten, n_changed), (text, 0))

    def test_relative_sources_are_unchanged(self):
        text = '  source = "../terraform-aws-network"\n  source = "./db_instance"\n'
        rewritten, n_changed = rewrite_tf_text(text, self.source_re)
        self.assertEqual((rewritten, n_changed), (text, 0))


class RewriteTarballTests(unittest.TestCase):
    def setUp(self):
        self.source_re = build_source_re("c0x12c")

    def test_returns_none_when_no_bare_sources_exist(self):
        blob = _make_tarball(
            [
                {
                    "name": "main.tf",
                    "body": b'module "db" {\n  source = "terraform.c0x12c.com/c0x12c/rds/aws"\n}\n',
                }
            ]
        )
        self.assertEqual(rewrite_tarball(blob, self.source_re), (None, []))

    def test_preserves_non_tf_bytes_and_tf_metadata(self):
        blob = _make_tarball(
            [
                {"name": "docs/", "body": None, "type": tarfile.DIRTYPE, "mode": 0o755},
                {
                    "name": "main.tf",
                    "body": b'module "db" {\n  source = "c0x12c/rds/aws"\n}\n',
                    "mode": 0o640,
                    "mtime": 1_701_234_567,
                    "uid": 77,
                    "gid": 88,
                },
                {
                    "name": "README.md",
                    "body": b"keep exact bytes\n",
                    "mode": 0o600,
                    "mtime": 1_701_234_568,
                },
            ]
        )

        rewritten_blob, changed_files = rewrite_tarball(blob, self.source_re)
        self.assertEqual(changed_files, ["main.tf"])
        members = _read_tarball(rewritten_blob)

        self.assertEqual(members["README.md"]["body"], b"keep exact bytes\n")
        self.assertEqual(members["main.tf"]["member"].mode, 0o640)
        self.assertEqual(members["main.tf"]["member"].mtime, 1_701_234_567)
        self.assertEqual(members["main.tf"]["member"].uid, 77)
        self.assertEqual(members["main.tf"]["member"].gid, 88)
        self.assertIn(
            ('source = "%s/c0x12c/rds/aws"' % REGISTRY_HOST).encode("utf-8"),
            members["main.tf"]["body"],
        )


class MigrationTests(unittest.TestCase):
    def test_iter_published_reads_index_json(self):
        client = _FakeS3Client(
            {
                "index.json": json.dumps(
                    {
                        "c0x12c/rds/aws": ["1.0.0", "1.1.0"],
                        "c0x12c/vpc/aws": ["2.0.0"],
                    }
                ).encode("utf-8")
            }
        )
        self.assertEqual(
            iter_published(client, "bucket"),
            [
                ("c0x12c/rds/aws", "1.0.0"),
                ("c0x12c/rds/aws", "1.1.0"),
                ("c0x12c/vpc/aws", "2.0.0"),
            ],
        )

    def test_dry_run_makes_zero_put_calls(self):
        tarball = _make_tarball(
            [{"name": "main.tf", "body": b'source = "c0x12c/rds/aws"\n'}]
        )
        client = _FakeS3Client(
            {
                "index.json": json.dumps({"c0x12c/rds/aws": ["1.0.0"]}).encode("utf-8"),
                "modules/c0x12c/rds/aws/1.0.0.tar.gz": tarball,
            }
        )
        summary = migrate(client, "bucket", "c0x12c", execute=False)
        self.assertEqual(summary, {"scanned": 1, "rewritten": 1, "skipped": 0})
        self.assertEqual(client.put_calls, [])

    def test_execute_reuploads_same_key_and_never_index_json(self):
        tarball = _make_tarball(
            [{"name": "main.tf", "body": b'source = "c0x12c/rds/aws"\n'}]
        )
        client = _FakeS3Client(
            {
                "index.json": json.dumps({"c0x12c/rds/aws": ["1.0.0"]}).encode("utf-8"),
                "modules/c0x12c/rds/aws/1.0.0.tar.gz": tarball,
            }
        )
        summary = migrate(client, "bucket", "c0x12c", execute=True)
        self.assertEqual(summary, {"scanned": 1, "rewritten": 1, "skipped": 0})
        self.assertEqual(
            [call["Key"] for call in client.put_calls],
            ["modules/c0x12c/rds/aws/1.0.0.tar.gz"],
        )

    def test_running_migrate_twice_is_idempotent_end_to_end(self):
        tarball = _make_tarball(
            [{"name": "main.tf", "body": b'source = "c0x12c/rds/aws"\n'}]
        )
        client = _FakeS3Client(
            {
                "index.json": json.dumps({"c0x12c/rds/aws": ["1.0.0"]}).encode("utf-8"),
                "modules/c0x12c/rds/aws/1.0.0.tar.gz": tarball,
            }
        )
        first = migrate(client, "bucket", "c0x12c", execute=True)
        second = migrate(client, "bucket", "c0x12c", execute=True)
        self.assertEqual(first, {"scanned": 1, "rewritten": 1, "skipped": 0})
        self.assertEqual(second, {"scanned": 1, "rewritten": 0, "skipped": 1})
        self.assertEqual(len(client.put_calls), 1)


class CliTests(unittest.TestCase):
    def test_main_uses_lazy_boto3_client_and_execute_note(self):
        tarball = _make_tarball(
            [{"name": "main.tf", "body": b'source = "c0x12c/rds/aws"\n'}]
        )
        client = _FakeS3Client(
            {
                "index.json": json.dumps({"c0x12c/rds/aws": ["1.0.0"]}).encode("utf-8"),
                "modules/c0x12c/rds/aws/1.0.0.tar.gz": tarball,
            }
        )
        fake_boto3 = _FakeBoto3Module(client)
        with mock.patch.dict(sys.modules, {"boto3": fake_boto3}), mock.patch.dict(
            os.environ, {"R2_ENDPOINT": "https://r2.example.invalid"}, clear=False
        ), mock.patch("sys.stdout", new_callable=io.StringIO) as stdout:
            result = migrate_r2_source_host.main(["--r2-bucket", "bucket", "--execute"])

        self.assertEqual(result, 0)
        self.assertEqual(fake_boto3.calls, [("s3", "https://r2.example.invalid")])
        self.assertIn("NOTE: re-uploads overwrite live R2 objects", stdout.getvalue())


if __name__ == "__main__":
    unittest.main()
