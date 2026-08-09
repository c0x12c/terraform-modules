#!/usr/bin/env python3
"""Fail when a module's default engine version is no longer orderable on AWS.

This catches a defect class that PR-triggered CI structurally cannot: the
module does not change, AWS does. `terraform-aws-rds` defaulted to Postgres
16.4 for months; the day AWS retired that minor version every greenfield
`apply` on the module defaults started failing with

    InvalidParameterCombination: Cannot find version 16.4 for postgres

and nothing went red, because there was no PR to attach a test to. `fmt`,
`validate`, `tflint`, `plan`, and every mocked test still pass - only the real
CreateDBInstance call rejects it. Existing instances are unaffected, so the
break stays invisible until someone stands up a new database.

Read-only: describe/list calls only, no resources created. Run it on a
schedule with credentials that can do nothing else.

    python3 scripts/check_engine_version_freshness.py [--repo-root <path>]
                                                      [--region <region>]
                                                      [--report-file <path>]

Exit 0 when every declared default is still offered, 1 when any is retired or
a check could not be completed. Stdlib only apart from the `aws` CLI, which
the GitHub runner already ships.
"""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

# Each entry: which module, which variable, and how to ask AWS what exists.
#
# Only AWS-MANAGED versions belong here - versions AWS retires on its own
# schedule regardless of what this repo does. Helm chart and container image
# versions are deliberately excluded: those are pinned deliberately, an old
# one keeps working, and Dependabot already covers them. A check that fires on
# "not the newest" rather than "no longer exists" would be noise, and a noisy
# gate gets muted, which costs more than it saves.
CHECKS = [
    {
        "module": "terraform-aws-documentdb",
        "variable": "engine_version",
        "service": "docdb",
        "describe": lambda region, _: [
            "aws", "docdb", "describe-db-engine-versions",
            "--engine", "docdb", "--region", region,
            "--query", "DBEngineVersions[].EngineVersion", "--output", "json",
        ],
    },
    {
        "module": "terraform-aws-elasticache",
        "variable": "engine_version",
        "service": "elasticache",
        # The module's `engine` variable selects redis or valkey; the default
        # engine_version is only meaningful against the default engine.
        "engine_variable": "engine",
        "describe": lambda region, engine: [
            "aws", "elasticache", "describe-cache-engine-versions",
            "--engine", engine or "redis", "--region", region,
            "--query", "CacheEngineVersions[].EngineVersion", "--output", "json",
        ],
    },
    {
        "module": "terraform-aws-opensearch",
        "variable": "engine_version",
        "service": "opensearch",
        "describe": lambda region, _: [
            "aws", "opensearch", "list-versions", "--region", region,
            "--query", "Versions", "--output", "json",
        ],
    },
    {
        "module": "terraform-aws-eks-cluster",
        "variable": "cluster_version",
        "service": "eks",
        "describe": lambda region, _: [
            "aws", "eks", "describe-cluster-versions", "--region", region,
            "--query", "clusterVersions[].clusterVersion", "--output", "json",
        ],
    },
]

# `variable "x" { ... default = "y" ... }` - deliberately simple. A default
# this check cannot parse is reported as UNPARSED, never silently skipped.
_VAR_BLOCK = r'variable\s+"%s"\s*\{(.*?)\n\}'
_DEFAULT = r'default\s*=\s*"([^"]+)"'


def declared_default(module_dir: Path, variable: str):
    """Return the literal default for `variable`, or None if there is none."""
    path = module_dir / "variables.tf"
    if not path.exists():
        return None
    block = re.search(_VAR_BLOCK % re.escape(variable),
                      path.read_text(encoding="utf-8"), re.S)
    if not block:
        return None
    found = re.search(_DEFAULT, block.group(1))
    return found.group(1) if found else None


def _first_useful_line(output: str, returncode: int) -> str:
    """The AWS CLI trails errors with "Additional error details: / Type: Sender",
    so the LAST line is the least informative one. Take the first line that
    actually names the failure."""
    for line in (output or "").splitlines():
        line = line.strip()
        if line and not line.startswith(("Additional error details", "Type:")):
            return line
    return "exit %d" % returncode


def offered_versions(command):
    """Run a read-only describe call; return (versions, error)."""
    try:
        proc = subprocess.run(command, capture_output=True, text=True,
                              timeout=60)
    except FileNotFoundError:
        return None, "aws CLI not found on PATH"
    except subprocess.TimeoutExpired:
        return None, "timed out after 60s"
    if proc.returncode != 0:
        return None, _first_useful_line(proc.stderr or proc.stdout,
                                        proc.returncode)
    try:
        return json.loads(proc.stdout), None
    except json.JSONDecodeError as exc:
        return None, "unparseable response: %s" % exc


def _matches(declared, offered):
    """OpenSearch reports `OpenSearch_2.13`; others report bare versions."""
    if declared in offered:
        return True
    return any(v.endswith("_" + declared) or declared.endswith("_" + v)
               for v in offered)


def run_checks(root: Path, region: str):
    results = []
    for check in CHECKS:
        module_dir = root / check["module"]
        name = "%s/%s" % (check["module"], check["variable"])

        if not module_dir.exists():
            results.append((name, "SKIP", "module not present in this repo"))
            continue

        declared = declared_default(module_dir, check["variable"])
        if declared is None:
            # No default is the *desired* end state (see terraform-aws-rds,
            # where engine_version is required). Nothing can rot.
            results.append((name, "OK", "no default declared - nothing to rot"))
            continue

        engine = None
        if check.get("engine_variable"):
            engine = declared_default(module_dir, check["engine_variable"])

        offered, error = offered_versions(check["describe"](region, engine))
        if error:
            # An unanswered question is a failure, not a pass. A check that
            # goes green when it could not reach AWS is worse than no check.
            results.append((name, "ERROR", "could not query AWS: %s" % error))
            continue

        if _matches(declared, offered):
            results.append((name, "OK", "%s is still offered" % declared))
        else:
            newest = ", ".join(sorted(offered)[-3:]) if offered else "(none)"
            results.append((
                name, "RETIRED",
                "default %s is NOT offered in %s. Currently available "
                "(newest few): %s" % (declared, region, newest)))
    return results


def render(results, region):
    lines = ["# Engine version freshness", "",
             "Region checked: `%s`" % region, "",
             "| Module / variable | Status | Detail |",
             "| --- | --- | --- |"]
    for name, status, detail in results:
        lines.append("| `%s` | %s | %s |" % (name, status, detail))
    return "\n".join(lines) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo-root", default=".", type=Path)
    ap.add_argument("--region", default="us-west-2",
                    help="AWS region to query; version availability is "
                         "region-specific.")
    ap.add_argument("--report-file", type=Path,
                    help="Write a markdown report here (for the failure issue).")
    args = ap.parse_args()

    results = run_checks(args.repo_root, args.region)

    for name, status, detail in results:
        stream = sys.stdout if status in ("OK", "SKIP") else sys.stderr
        print("%-8s %-46s %s" % (status, name, detail), file=stream)

    if args.report_file:
        args.report_file.write_text(render(results, args.region),
                                    encoding="utf-8")

    bad = [r for r in results if r[1] in ("RETIRED", "ERROR")]
    if bad:
        print("\n%d of %d checks need attention." % (len(bad), len(results)),
              file=sys.stderr)
        return 1
    print("\nAll %d declared engine-version defaults are still offered."
          % len(results))
    return 0


if __name__ == "__main__":
    sys.exit(main())
