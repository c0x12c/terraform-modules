#!/usr/bin/env python3

import io
import json
import sys
import types
import urllib.error

import pytest

import scripts.registry_health_check as health


class _FakeHeaders(dict):
    def get(self, key, default=None):
        return super().get(key, default)


class _FakeResponse:
    def __init__(self, status, headers=None, body=b""):
        self.status = status
        self.headers = _FakeHeaders(headers or {})
        self._body = body

    def read(self, amount=-1):
        if amount is None or amount < 0:
            return self._body
        return self._body[:amount]

    def close(self):
        return None


class _FakeS3Client:
    NoSuchKey = types.SimpleNamespace()

    def __init__(self, objects):
        self.objects = {key: value for key, value in objects.items()}

    def get_object(self, Bucket, Key):
        if Key not in self.objects:
            raise KeyError(Key)
        return {"Body": io.BytesIO(self.objects[Key])}


def _versions_body(*versions):
    return json.dumps(
        {"modules": [{"versions": [{"version": version} for version in versions]}]}
    ).encode("utf-8")


def _http_error(url, status, headers=None):
    return urllib.error.HTTPError(
        url=url,
        code=status,
        msg="error",
        hdrs=_FakeHeaders(headers or {}),
        fp=None,
    )


def _url_of(req):
    # The script wraps urls in urllib.request.Request (to set a User-Agent);
    # tests key on the url string, so normalize either form.
    return req.full_url if hasattr(req, "full_url") else req


def _install_urlopen(monkeypatch, mapping, calls):
    def fake_urlopen(req, timeout=30):
        url = _url_of(req)
        calls.append(url)
        value = mapping[url]
        if isinstance(value, Exception):
            raise value
        status, headers, body = value
        return _FakeResponse(status, headers, body)

    monkeypatch.setattr(health.urllib.request, "urlopen", fake_urlopen)


def test_request_sets_user_agent(monkeypatch):
    # Regression: Cloudflare 403s the default "Python-urllib/x" agent, so every
    # probe must send an explicit User-Agent.
    seen = {}

    def fake_urlopen(req, timeout=30):
        seen["ua"] = req.get_header("User-agent")
        return _FakeResponse(200, {}, b"ok")

    monkeypatch.setattr(health.urllib.request, "urlopen", fake_urlopen)
    health._request("https://registry.test/anything")
    assert seen["ua"] == health.USER_AGENT


def test_module_key_happy_and_malformed():
    assert (
        health.module_key("terraform-aws-vpc", "c0x12c") == "c0x12c/vpc/aws"
    )
    assert health.module_key("bad-name", "c0x12c") is None


def test_check_coverage_cases():
    assert (
        health.check_coverage(
            {"terraform-aws-vpc": "1.0.0"},
            {"c0x12c/vpc/aws": ["1.0.0"]},
            "c0x12c",
            {},
        )
        == []
    )
    assert len(
        health.check_coverage(
            {"terraform-aws-vpc": "1.0.0"},
            {"c0x12c/vpc/aws": ["0.9.0"]},
            "c0x12c",
            {},
        )
    ) == 1
    assert (
        health.check_coverage(
            {"terraform-aws-seeded": "0.0.0"},
            {},
            "c0x12c",
            {},
        )
        == []
    )
    assert (
        health.check_coverage(
            {"terraform-aws-opensearch": "0.3.16"},
            {},
            "c0x12c",
            health.EXCEPTIONS,
        )
        == []
    )
    discrepancies = health.check_coverage(
        {"terraform-aws-opensearch": "0.3.16"},
        {"c0x12c/opensearch/aws": ["0.3.16"]},
        "c0x12c",
        health.EXCEPTIONS,
    )
    assert len(discrepancies) == 1
    assert "exception no longer needed" in discrepancies[0]


def test_check_resolvability_all_green(monkeypatch):
    calls = []
    _install_urlopen(
        monkeypatch,
        {
            "https://registry.test/v1/modules/c0x12c/vpc/aws/versions": (
                200,
                {},
                _versions_body("1.0.0"),
            ),
            "https://registry.test/v1/modules/c0x12c/vpc/aws/1.0.0/download": (
                204,
                {"X-Terraform-Get": "https://archive.test/vpc-1.0.0.tgz"},
                b"",
            ),
            "https://archive.test/vpc-1.0.0.tgz": (200, {}, b"x"),
        },
        calls,
    )
    assert (
        health.check_resolvability(
            {"c0x12c/vpc/aws": ["1.0.0"]},
            "https://registry.test",
            retries=3,
            backoff=0,
        )
        == []
    )


def test_check_resolvability_download_status_must_be_204(monkeypatch):
    calls = []
    _install_urlopen(
        monkeypatch,
        {
            "https://registry.test/v1/modules/c0x12c/vpc/aws/versions": (
                200,
                {},
                _versions_body("1.0.0"),
            ),
            "https://registry.test/v1/modules/c0x12c/vpc/aws/1.0.0/download": (
                200,
                {"X-Terraform-Get": "https://archive.test/vpc-1.0.0.tgz"},
                b"",
            ),
        },
        calls,
    )
    discrepancies = health.check_resolvability(
        {"c0x12c/vpc/aws": ["1.0.0"]},
        "https://registry.test",
        retries=3,
        backoff=0,
    )
    assert len(discrepancies) == 1
    assert "download status=200" in discrepancies[0]


def test_check_resolvability_download_requires_header(monkeypatch):
    calls = []
    _install_urlopen(
        monkeypatch,
        {
            "https://registry.test/v1/modules/c0x12c/vpc/aws/versions": (
                200,
                {},
                _versions_body("1.0.0"),
            ),
            "https://registry.test/v1/modules/c0x12c/vpc/aws/1.0.0/download": (
                204,
                {},
                b"",
            ),
        },
        calls,
    )
    discrepancies = health.check_resolvability(
        {"c0x12c/vpc/aws": ["1.0.0"]},
        "https://registry.test",
        retries=3,
        backoff=0,
    )
    assert len(discrepancies) == 1
    assert "x-terraform-get=False" in discrepancies[0]


def test_check_resolvability_archive_404(monkeypatch):
    calls = []
    _install_urlopen(
        monkeypatch,
        {
            "https://registry.test/v1/modules/c0x12c/vpc/aws/versions": (
                200,
                {},
                _versions_body("1.0.0"),
            ),
            "https://registry.test/v1/modules/c0x12c/vpc/aws/1.0.0/download": (
                204,
                {"X-Terraform-Get": "https://archive.test/vpc-1.0.0.tgz"},
                b"",
            ),
            "https://archive.test/vpc-1.0.0.tgz": _http_error(
                "https://archive.test/vpc-1.0.0.tgz", 404
            ),
        },
        calls,
    )
    discrepancies = health.check_resolvability(
        {"c0x12c/vpc/aws": ["1.0.0"]},
        "https://registry.test",
        retries=3,
        backoff=0,
    )
    assert len(discrepancies) == 1
    assert "archive status=404" in discrepancies[0]


def test_check_resolvability_versions_omits_index_version(monkeypatch):
    calls = []
    _install_urlopen(
        monkeypatch,
        {
            "https://registry.test/v1/modules/c0x12c/vpc/aws/versions": (
                200,
                {},
                _versions_body("0.9.0"),
            ),
            "https://registry.test/v1/modules/c0x12c/vpc/aws/1.0.0/download": (
                204,
                {"X-Terraform-Get": "https://archive.test/vpc-1.0.0.tgz"},
                b"",
            ),
            "https://archive.test/vpc-1.0.0.tgz": (200, {}, b"x"),
        },
        calls,
    )
    discrepancies = health.check_resolvability(
        {"c0x12c/vpc/aws": ["1.0.0"]},
        "https://registry.test",
        retries=3,
        backoff=0,
    )
    assert len(discrepancies) == 1
    assert "not served by /versions" in discrepancies[0]


def test_check_resolvability_retries_transient(monkeypatch):
    calls = []
    sleep_calls = []
    mapping = {
        "https://registry.test/v1/modules/c0x12c/vpc/aws/versions": [
            urllib.error.URLError("temporary"),
            (200, {}, _versions_body("1.0.0")),
        ],
        "https://registry.test/v1/modules/c0x12c/vpc/aws/1.0.0/download": [
            (204, {"X-Terraform-Get": "https://archive.test/vpc-1.0.0.tgz"}, b"")
        ],
        "https://archive.test/vpc-1.0.0.tgz": [(200, {}, b"x")],
    }

    def fake_urlopen(req, timeout=30):
        url = _url_of(req)
        calls.append(url)
        value = mapping[url].pop(0)
        if isinstance(value, Exception):
            raise value
        status, headers, body = value
        return _FakeResponse(status, headers, body)

    monkeypatch.setattr(health.urllib.request, "urlopen", fake_urlopen)
    monkeypatch.setattr(health.time, "sleep", lambda seconds: sleep_calls.append(seconds))
    discrepancies = health.check_resolvability(
        {"c0x12c/vpc/aws": ["1.0.0"]},
        "https://registry.test",
        retries=3,
        backoff=0.25,
    )
    assert discrepancies == []
    assert sleep_calls == [0.25]


def test_download_404_not_retried(monkeypatch):
    download_url = "https://registry.test/v1/modules/c0x12c/vpc/aws/1.0.0/download"
    calls = []
    _install_urlopen(
        monkeypatch,
        {
            "https://registry.test/v1/modules/c0x12c/vpc/aws/versions": (
                200,
                {},
                _versions_body("1.0.0"),
            ),
            download_url: _http_error(download_url, 404),
        },
        calls,
    )
    discrepancies = health.check_resolvability(
        {"c0x12c/vpc/aws": ["1.0.0"]},
        "https://registry.test",
        retries=3,
        backoff=0,
    )
    assert len(discrepancies) == 1
    assert calls.count(download_url) == 1


def test_main_end_to_end_and_skip_resolve(monkeypatch, tmp_path):
    report_file = tmp_path / "report.md"
    manifest_file = tmp_path / "manifest.json"
    manifest_file.write_text(json.dumps({"terraform-aws-vpc": "1.0.0"}), encoding="utf-8")

    fake_client = _FakeS3Client(
        {"index.json": json.dumps({"c0x12c/vpc/aws": ["1.0.0"]}).encode("utf-8")}
    )
    monkeypatch.setenv("R2_ENDPOINT", "https://r2.test")
    monkeypatch.setitem(sys.modules, "boto3", types.SimpleNamespace(client=lambda *args, **kwargs: fake_client))

    calls = []
    _install_urlopen(
        monkeypatch,
        {
            "https://registry.test/v1/modules/c0x12c/vpc/aws/versions": (
                200,
                {},
                _versions_body("1.0.0"),
            ),
            "https://registry.test/v1/modules/c0x12c/vpc/aws/1.0.0/download": (
                204,
                {"X-Terraform-Get": "https://archive.test/vpc-1.0.0.tgz"},
                b"",
            ),
            "https://archive.test/vpc-1.0.0.tgz": (200, {}, b"x"),
        },
        calls,
    )
    assert (
        health.main(
            [
                "--r2-bucket",
                "registry",
                "--manifest",
                str(manifest_file),
                "--registry-base",
                "https://registry.test",
                "--report-file",
                str(report_file),
            ]
        )
        == 0
    )
    assert "All registry health checks passed" in report_file.read_text(encoding="utf-8")

    manifest_file.write_text(json.dumps({"terraform-aws-vpc": "2.0.0"}), encoding="utf-8")
    assert (
        health.main(
            [
                "--r2-bucket",
                "registry",
                "--manifest",
                str(manifest_file),
                "--registry-base",
                "https://registry.test",
                "--report-file",
                str(report_file),
                "--skip-resolve",
            ]
        )
        == 1
    )
    report_text = report_file.read_text(encoding="utf-8")
    assert "missing from index.json" in report_text
    assert "## Resolvability" in report_text
    assert calls.count("https://registry.test/v1/modules/c0x12c/vpc/aws/versions") == 1
