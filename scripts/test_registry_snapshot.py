import io
import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent))

from registry_snapshot import (  # noqa: E402
    content_type_for,
    safe_relative_path,
    missing_index_coverage,
    restore,
    snapshot,
)


class _FakeS3Client:
    """Fake with real pagination, because pagination is the branch that rots.

    page_size splits the listing so the continuation-token path is exercised
    rather than assumed.
    """

    def __init__(self, objects, page_size=1000):
        self.objects = dict(objects)
        self.page_size = page_size
        self.puts = []

    def list_objects_v2(self, Bucket, ContinuationToken=None):
        keys = sorted(self.objects)
        start = keys.index(ContinuationToken) if ContinuationToken else 0
        window = keys[start : start + self.page_size]
        nxt = keys[start + self.page_size : start + self.page_size + 1]
        page = {"Contents": [{"Key": k, "Size": len(self.objects[k])} for k in window]}
        if nxt:
            page["IsTruncated"] = True
            page["NextContinuationToken"] = nxt[0]
        else:
            page["IsTruncated"] = False
        return page

    def get_object(self, Bucket, Key):
        return {"Body": io.BytesIO(self.objects[Key])}

    def put_object(self, Bucket, Key, Body, ContentType=None):
        self.puts.append((Key, Body, ContentType))
        self.objects[Key] = Body


def _index(**mods):
    return json.dumps(mods).encode("utf-8")


def _bucket(page_size=1000):
    return _FakeS3Client(
        {
            "index.json": _index(**{"c0x12c/rds/aws": ["1.0.0", "1.1.0"]}),
            "modules/c0x12c/rds/aws/1.0.0.tar.gz": b"tarball-one",
            "modules/c0x12c/rds/aws/1.1.0.tar.gz": b"tarball-two",
        },
        page_size=page_size,
    )


def test_snapshot_writes_objects_and_matching_checksums(tmp_path):
    client = _bucket()

    manifest = snapshot(client, "b", tmp_path, now="2026-01-01T00:00:00Z")

    assert manifest["object_count"] == 3
    assert manifest["generated_at"] == "2026-01-01T00:00:00Z"
    for key, meta in manifest["objects"].items():
        body = (tmp_path / "objects" / key).read_bytes()
        assert len(body) == meta["size"]
        import hashlib

        assert hashlib.sha256(body).hexdigest() == meta["sha256"]


def test_snapshot_follows_pagination(tmp_path):
    # One object per page: every continuation hop must be taken to see all three.
    client = _bucket(page_size=1)

    manifest = snapshot(client, "b", tmp_path, now="2026-01-01T00:00:00Z")

    assert manifest["object_count"] == 3


def test_snapshot_aborts_when_index_absent(tmp_path):
    client = _FakeS3Client({"modules/c0x12c/rds/aws/1.0.0.tar.gz": b"x"})

    with pytest.raises(SystemExit, match="no index.json"):
        snapshot(client, "b", tmp_path)


def test_snapshot_aborts_when_index_entry_has_no_tarball(tmp_path):
    client = _FakeS3Client(
        {
            "index.json": _index(**{"c0x12c/rds/aws": ["9.9.9"]}),
            "modules/c0x12c/rds/aws/1.0.0.tar.gz": b"x",
        }
    )

    with pytest.raises(SystemExit, match="no tarball"):
        snapshot(client, "b", tmp_path)


def test_snapshot_aborts_on_empty_bucket(tmp_path):
    with pytest.raises(SystemExit, match="empty snapshot"):
        snapshot(_FakeS3Client({}), "b", tmp_path)


def test_snapshot_aborts_when_index_is_not_json(tmp_path):
    client = _FakeS3Client({"index.json": b"not json at all"})

    with pytest.raises(SystemExit, match="does not parse"):
        snapshot(client, "b", tmp_path)


def test_restore_without_apply_writes_nothing(tmp_path):
    snapshot(_bucket(), "b", tmp_path, now="2026-01-01T00:00:00Z")
    target = _FakeS3Client({})

    result = restore(target, "restored", tmp_path)

    assert target.puts == []
    assert result == {"uploaded": 0, "planned": 3}


def test_restore_aborts_on_checksum_mismatch(tmp_path):
    snapshot(_bucket(), "b", tmp_path, now="2026-01-01T00:00:00Z")
    tampered = tmp_path / "objects" / "modules/c0x12c/rds/aws/1.0.0.tar.gz"
    tampered.write_bytes(b"corrupted")
    target = _FakeS3Client({})

    with pytest.raises(SystemExit, match="1.0.0.tar.gz"):
        restore(target, "restored", tmp_path, apply=True)

    assert target.puts == []


def test_restore_apply_sets_content_types(tmp_path):
    snapshot(_bucket(), "b", tmp_path, now="2026-01-01T00:00:00Z")
    target = _FakeS3Client({})

    restore(target, "restored", tmp_path, apply=True)

    types = {key: ctype for key, _, ctype in target.puts}
    assert types["index.json"] == "application/json"
    assert types["modules/c0x12c/rds/aws/1.0.0.tar.gz"] == "application/gzip"


def test_round_trip_reproduces_the_bucket_byte_for_byte(tmp_path):
    source = _bucket()
    snapshot(source, "b", tmp_path, now="2026-01-01T00:00:00Z")
    target = _FakeS3Client({})

    restore(target, "restored", tmp_path, apply=True)

    assert target.objects == source.objects


def test_missing_index_coverage_accepts_partial_version_presence():
    # One of two versions present is enough: the module resolves, and a snapshot
    # should not refuse over a version that was legitimately never published.
    keys = {"modules/c0x12c/rds/aws/1.0.0.tar.gz"}

    assert missing_index_coverage({"c0x12c/rds/aws": ["1.0.0", "2.0.0"]}, keys) == []
    assert missing_index_coverage({"c0x12c/vpc/aws": ["1.0.0"]}, keys) == ["c0x12c/vpc/aws"]


def test_content_type_for_unknown_suffix_is_octet_stream():
    assert content_type_for("weird.bin") == "application/octet-stream"


class _TruncatedNoTokenClient(_FakeS3Client):
    """Reports more results but hands back no way to fetch them."""

    def list_objects_v2(self, Bucket, ContinuationToken=None):
        page = super().list_objects_v2(Bucket, ContinuationToken)
        page["IsTruncated"] = True
        page.pop("NextContinuationToken", None)
        return page


def test_snapshot_aborts_when_truncated_without_a_continuation_token(tmp_path):
    # A partial listing that looks complete is worse than no backup at all.
    client = _TruncatedNoTokenClient(_bucket().objects)

    with pytest.raises(SystemExit, match="continuation token"):
        snapshot(client, "b", tmp_path)


def test_snapshot_refuses_a_key_that_escapes_the_directory(tmp_path):
    client = _FakeS3Client(
        {
            "index.json": _index(**{"c0x12c/rds/aws": ["1.0.0"]}),
            "modules/c0x12c/rds/aws/1.0.0.tar.gz": b"ok",
            "../escaped.txt": b"nope",
        }
    )

    with pytest.raises(SystemExit, match="parent reference"):
        snapshot(client, "b", tmp_path)


def test_snapshot_refuses_an_absolute_key(tmp_path):
    client = _FakeS3Client(
        {
            "index.json": _index(**{"c0x12c/rds/aws": ["1.0.0"]}),
            "modules/c0x12c/rds/aws/1.0.0.tar.gz": b"ok",
            "/etc/passwd": b"nope",
        }
    )

    with pytest.raises(SystemExit, match="absolute object key"):
        snapshot(client, "b", tmp_path)


def test_safe_relative_path_accepts_ordinary_keys(tmp_path):
    resolved = safe_relative_path(tmp_path, "modules/c0x12c/rds/aws/1.0.0.tar.gz")

    assert tmp_path.resolve() in resolved.parents
