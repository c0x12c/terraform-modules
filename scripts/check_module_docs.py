#!/usr/bin/env python3
"""Check a module's README docs are current, ignoring the Providers table.

The CI docs check used to compare the WHOLE terraform-docs output against the
committed README. The Providers table's versions come from the
.terraform.lock.hcl that the preceding `terraform init` resolves, so an
upstream provider release changes that table's content without the module's
inputs or outputs changing at all - reddening a PR that touched nothing
related. This script asserts inputs/outputs/requirements/modules/resources
match, which is what the check's own annotation text already claims to
assert, and deliberately excludes Providers from the comparison.

Excluding a section can only make a passing module keep passing: it can never
turn a currently-passing README into a failure, so this requires zero changes
to any module's README.

    python3 scripts/check_module_docs.py <module> --terraform-docs <path>

Exit 0 when the docs (minus Providers) are current, 1 otherwise (message on
stderr naming the module and how to regenerate). Stdlib only.
"""
import argparse
import re
import subprocess
import sys
from pathlib import Path

BEGIN_MARKER = "<!-- BEGIN_TF_DOCS -->"
END_MARKER = "<!-- END_TF_DOCS -->"

_PROVIDERS_HEADING_RE = re.compile(r"(?m)^##[ \t]+Providers[ \t]*$")
_NEXT_HEADING_RE = re.compile(r"(?m)^##[ \t]+")


def strip_providers_section(text: str) -> str:
    """Remove the '## Providers' section (heading through the next '## ' heading, or EOF)."""
    match = _PROVIDERS_HEADING_RE.search(text)
    if not match:
        return text
    next_match = _NEXT_HEADING_RE.search(text, match.end())
    end = next_match.start() if next_match else len(text)
    return text[: match.start()] + text[end:]


def configured_output_mode(module: str):
    """The output.mode from a module's .terraform-docs.yml, or None.

    Parsed rather than pulled in with a yaml dependency: this script is stdlib
    only, and the one key that matters sits in a two-level block.
    """
    config = Path(module) / ".terraform-docs.yml"
    if not config.is_file():
        return None
    in_output = False
    for raw in config.read_text(encoding="utf-8").splitlines():
        if re.match(r"^output:\s*$", raw):
            in_output = True
            continue
        if not in_output:
            continue
        if raw.strip() and not raw[:1].isspace():
            break
        mode = re.match(r"\s+mode:\s*(\S+)", raw)
        if mode:
            return mode.group(1).strip().strip("\"'")
    return None


def extract_marked_region(readme_text: str):
    """Return the text between the BEGIN/END markers, or None if absent/malformed."""
    begin = readme_text.find(BEGIN_MARKER)
    if begin == -1:
        return None
    begin += len(BEGIN_MARKER)
    end = readme_text.find(END_MARKER, begin)
    if end == -1:
        return None
    return readme_text[begin:end]


def run_terraform_docs(binary: str, module: str) -> str:
    # `--output-file ""` forces stdout even when the module's own
    # .terraform-docs.yml sets output.file/output.mode (as
    # terraform-aws-health-notification and terraform-datadog-aws-integration
    # do) - without it terraform-docs writes the README directly instead of
    # printing. terraform-docs still auto-loads that config's other settings
    # (e.g. `lockfile: false`) from the target directory either way.
    result = subprocess.run(
        [binary, "markdown", "table", "--output-file", "", module],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(
            "terraform-docs failed for %s: %s"
            % (module, (result.stderr or result.stdout).strip()),
            file=sys.stderr,
        )
        sys.exit(1)
    return result.stdout


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(
        description="Compare a module's committed terraform-docs output "
        "against freshly generated output, ignoring the Providers table."
    )
    parser.add_argument("module", help="module directory, e.g. terraform-aws-rds")
    parser.add_argument(
        "--terraform-docs", required=True, dest="terraform_docs",
        help="path to the terraform-docs binary to run",
    )
    args = parser.parse_args(argv)

    module = args.module
    readme_path = Path(module) / "README.md"
    if not readme_path.is_file():
        print(
            "%s has no README.md; cannot verify input/output docs. "
            "Add one with %s / %s markers (or a .terraform-docs.yml)."
            % (module, BEGIN_MARKER, END_MARKER),
            file=sys.stderr,
        )
        return 1

    committed = readme_path.read_text(encoding="utf-8")
    committed_region = extract_marked_region(committed)
    # Only an explicit output.mode: replace owns the whole README - terraform-docs
    # writes the file wholesale, so there are no markers to find and the whole
    # file is what to compare. Keying on the config file's mere EXISTENCE would
    # be wrong in both directions: an inject module that LOST its markers would
    # slide into whole-file comparison instead of failing, which is the case
    # this check exists to catch.
    if configured_output_mode(module) == "replace":
        committed_region = committed
    elif committed_region is None:
        print(
            "%s has no %s / %s markers in README.md; cannot verify "
            "input/output docs. Add the markers (or a .terraform-docs.yml "
            "with output.mode replace)."
            % (module, BEGIN_MARKER, END_MARKER),
            file=sys.stderr,
        )
        return 1

    generated = run_terraform_docs(args.terraform_docs, module)

    generated_cmp = strip_providers_section(generated).strip()
    committed_cmp = strip_providers_section(committed_region).strip()

    if generated_cmp == committed_cmp:
        return 0

    mode = configured_output_mode(module)
    if mode == "replace":
        remediation = "terraform-docs markdown table %s" % module
    else:
        remediation = (
            "terraform-docs markdown table --output-file README.md "
            "--output-mode inject %s" % module
        )
    print(
        "%s docs are out of date for a new/changed input or output "
        "(the Providers table is excluded from this comparison - its "
        "versions depend on the lock file, not on this module's inputs or "
        "outputs). Regenerate with: %s"
        % (module, remediation),
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    sys.exit(main())
