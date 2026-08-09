#!/usr/bin/env python3
"""Tests for check_engine_version_freshness.

The AWS calls are stubbed - the point is to prove the decision logic, not to
exercise the API. Notably: an unreachable AWS must FAIL, not pass silently.
"""
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import check_engine_version_freshness as freshness  # noqa: E402

SCRIPT = Path(__file__).resolve().parent / "check_engine_version_freshness.py"

FAILURES = []


def check(name, condition, detail=""):
    if condition:
        print("ok   %s" % name)
    else:
        print("FAIL %s %s" % (name, detail))
        FAILURES.append(name)


def write_module(root: Path, module: str, body: str) -> Path:
    d = root / module
    d.mkdir(parents=True, exist_ok=True)
    (d / "variables.tf").write_text(body, encoding="utf-8")
    return d


def var(name: str, default=None, extra="") -> str:
    lines = ['variable "%s" {' % name, '  type        = string']
    if default is not None:
        lines.append('  default     = "%s"' % default)
    if extra:
        lines.append(extra)
    lines.append("}")
    return "\n".join(lines) + "\n"


def test_declared_default(tmp: Path):
    d = write_module(tmp, "m1", var("engine_version", "16.4"))
    check("reads a declared default",
          freshness.declared_default(d, "engine_version") == "16.4")

    d = write_module(tmp, "m2", var("engine_version"))
    check("returns None when there is no default",
          freshness.declared_default(d, "engine_version") is None)

    d = write_module(tmp, "m3", var("other", "1.0"))
    check("returns None when the variable is absent",
          freshness.declared_default(d, "engine_version") is None)

    # A validation block must not be mistaken for the default.
    d = write_module(tmp, "m4", var(
        "engine_version", "18.4",
        extra='  validation {\n'
              '    condition     = can(regex("^[0-9]", var.engine_version))\n'
              '    error_message = "default = \\"nope\\" in a message"\n'
              '  }'))
    check("picks the real default, not a string inside a validation block",
          freshness.declared_default(d, "engine_version") == "18.4",
          freshness.declared_default(d, "engine_version"))


def test_matches():
    check("exact match", freshness._matches("16.10", ["16.9", "16.10"]))
    check("no match on a retired version",
          not freshness._matches("16.4", ["16.10", "16.11"]))
    check("OpenSearch-style prefix match",
          freshness._matches("OpenSearch_2.13", ["OpenSearch_2.13"]))
    check("bare version matches an OpenSearch_-prefixed offering",
          freshness._matches("2.13", ["OpenSearch_2.13"]))
    check("empty offering list never matches",
          not freshness._matches("1.0", []))


def test_first_useful_line():
    # The AWS CLI trails errors with boilerplate; the last line is useless.
    noisy = ("aws: [ERROR]: An error occurred (AccessDenied) ...\n"
             "\nAdditional error details:\nType: Sender")
    check("picks the line that names the failure",
          "AccessDenied" in freshness._first_useful_line(noisy, 254))
    check("falls back to the exit code when there is nothing useful",
          freshness._first_useful_line(
              "Additional error details:\nType: Sender", 1) == "exit 1")
    check("falls back on empty output",
          freshness._first_useful_line("", 3) == "exit 3")


def test_run_checks(tmp: Path, monkeypatched):
    root = tmp / "repo"
    write_module(root, "terraform-aws-documentdb", var("engine_version", "5.0.0"))
    write_module(root, "terraform-aws-elasticache",
                 var("engine", "redis") + var("engine_version", "7.1"))
    write_module(root, "terraform-aws-opensearch",
                 var("engine_version", "OpenSearch_2.13"))
    # eks-cluster deliberately absent -> SKIP

    monkeypatched({
        "docdb": ["5.0.0", "4.0.0"],
        "elasticache": ["7.0", "7.1"],
        "opensearch": ["OpenSearch_2.13"],
    })
    results = dict((n, (s, d)) for n, s, d in
                   freshness.run_checks(root, "us-west-2"))
    check("still-offered default is OK",
          results["terraform-aws-documentdb/engine_version"][0] == "OK")
    check("absent module is SKIP",
          results["terraform-aws-eks-cluster/cluster_version"][0] == "SKIP")

    monkeypatched({
        "docdb": ["5.0.1", "6.0.0"],
        "elasticache": ["7.0", "7.1"],
        "opensearch": ["OpenSearch_2.13"],
    })
    results = dict((n, (s, d)) for n, s, d in
                   freshness.run_checks(root, "us-west-2"))
    status, detail = results["terraform-aws-documentdb/engine_version"]
    check("retired default is RETIRED", status == "RETIRED", status)
    check("RETIRED detail names the version and the alternatives",
          "5.0.0" in detail and "6.0.0" in detail, detail)

    # The load-bearing case: AWS unreachable must not read as healthy.
    monkeypatched(None, error="AccessDenied")
    results = dict((n, (s, d)) for n, s, d in
                   freshness.run_checks(root, "us-west-2"))
    statuses = set(s for s, _ in results.values()) - {"SKIP"}
    check("unreachable AWS is ERROR, never OK", statuses == {"ERROR"}, statuses)

    # No default declared (the terraform-aws-rds end state) is healthy.
    write_module(root, "terraform-aws-documentdb", var("engine_version"))
    monkeypatched({"elasticache": ["7.1"], "opensearch": ["OpenSearch_2.13"]})
    results = dict((n, (s, d)) for n, s, d in
                   freshness.run_checks(root, "us-west-2"))
    status, detail = results["terraform-aws-documentdb/engine_version"]
    check("a required variable with no default is OK",
          status == "OK" and "no default" in detail, (status, detail))


def test_exit_codes(tmp: Path):
    """The real script against a repo with no modules: all SKIP -> exit 0."""
    empty = tmp / "empty"
    empty.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(
        [sys.executable, str(SCRIPT), "--repo-root", str(empty)],
        capture_output=True, text=True)
    check("all-SKIP run exits 0", proc.returncode == 0,
          "rc=%d %s" % (proc.returncode, proc.stderr))


def main():
    import tempfile

    def patcher(mapping, error=None):
        def fake(command):
            if error:
                return None, error
            for key, versions in (mapping or {}).items():
                if key in command:
                    return versions, None
            return [], None
        freshness.offered_versions = fake

    original = freshness.offered_versions
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        test_declared_default(tmp)
        test_matches()
        test_first_useful_line()
        test_run_checks(tmp, patcher)
        freshness.offered_versions = original
        test_exit_codes(tmp)

    if FAILURES:
        print("\n%d test(s) failed: %s" % (len(FAILURES), ", ".join(FAILURES)))
        return 1
    print("\nall tests passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
