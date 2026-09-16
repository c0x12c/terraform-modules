import stat
import subprocess
import sys
import textwrap
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent / "check_module_docs.py"

BASE_BODY = textwrap.dedent("""\
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.8 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.75 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the thing | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| id | The id |""")

NO_PROVIDERS_BODY = textwrap.dedent("""\
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.8 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the thing | `string` | n/a | yes |""")


def make_fake_terraform_docs(tmp_path: Path, output: str) -> Path:
    fake = tmp_path / "fake-terraform-docs.sh"
    fake.write_text("#!/bin/sh\ncat <<'DOCS_EOF'\n%s\nDOCS_EOF\n" % output, encoding="utf-8")
    fake.chmod(fake.stat().st_mode | stat.S_IEXEC | stat.S_IXGRP | stat.S_IXOTH)
    return fake


def make_module(tmp_path: Path, name: str, body: str, with_markers: bool = True) -> Path:
    module_dir = tmp_path / name
    module_dir.mkdir()
    if with_markers:
        content = "# %s\n\n<!-- BEGIN_TF_DOCS -->\n%s\n<!-- END_TF_DOCS -->\n" % (name, body)
    else:
        content = "# %s\n\nno markers here\n" % name
    (module_dir / "README.md").write_text(content, encoding="utf-8")
    return module_dir


def run_check(module_dir: Path, fake_docs: Path):
    return subprocess.run(
        [sys.executable, str(SCRIPT), str(module_dir), "--terraform-docs", str(fake_docs)],
        capture_output=True, text=True,
    )


def test_identical_docs_pass(tmp_path):
    module_dir = make_module(tmp_path, "terraform-aws-rds", BASE_BODY)
    fake = make_fake_terraform_docs(tmp_path, BASE_BODY)
    result = run_check(module_dir, fake)
    assert result.returncode == 0, result.stderr


def test_differing_providers_version_passes(tmp_path):
    # The whole point: an upstream provider release changes the resolved
    # version but must not fail a PR that touched nothing else.
    module_dir = make_module(tmp_path, "terraform-aws-rds", BASE_BODY)
    generated = BASE_BODY.replace("aws | >= 5.75", "aws | >= 5.90")
    fake = make_fake_terraform_docs(tmp_path, generated)
    result = run_check(module_dir, fake)
    assert result.returncode == 0, result.stderr


def test_differing_providers_row_count_passes(tmp_path):
    module_dir = make_module(tmp_path, "terraform-aws-rds", BASE_BODY)
    generated = BASE_BODY.replace(
        "| aws | >= 5.75 |", "| aws | >= 5.75 |\n| random | >= 3.6 |"
    )
    fake = make_fake_terraform_docs(tmp_path, generated)
    result = run_check(module_dir, fake)
    assert result.returncode == 0, result.stderr


def test_changed_input_name_fails(tmp_path):
    module_dir = make_module(tmp_path, "terraform-aws-rds", BASE_BODY)
    generated = BASE_BODY.replace("| name | Name of the thing", "| renamed | Name of the thing")
    fake = make_fake_terraform_docs(tmp_path, generated)
    result = run_check(module_dir, fake)
    assert result.returncode == 1
    assert "terraform-aws-rds" in result.stderr


def test_changed_output_fails(tmp_path):
    module_dir = make_module(tmp_path, "terraform-aws-rds", BASE_BODY)
    generated = BASE_BODY.replace("| id | The id |", "| id | A different description |")
    fake = make_fake_terraform_docs(tmp_path, generated)
    result = run_check(module_dir, fake)
    assert result.returncode == 1


def test_removed_input_fails(tmp_path):
    module_dir = make_module(tmp_path, "terraform-aws-rds", BASE_BODY)
    generated = BASE_BODY.replace("| name | Name of the thing | `string` | n/a | yes |\n", "")
    fake = make_fake_terraform_docs(tmp_path, generated)
    result = run_check(module_dir, fake)
    assert result.returncode == 1


def test_missing_markers_fails(tmp_path):
    module_dir = make_module(tmp_path, "terraform-aws-rds", BASE_BODY, with_markers=False)
    fake = make_fake_terraform_docs(tmp_path, BASE_BODY)
    result = run_check(module_dir, fake)
    assert result.returncode == 1
    assert "markers" in result.stderr


def test_providers_section_absent_from_both_passes(tmp_path):
    module_dir = make_module(tmp_path, "terraform-aws-rds", NO_PROVIDERS_BODY)
    fake = make_fake_terraform_docs(tmp_path, NO_PROVIDERS_BODY)
    result = run_check(module_dir, fake)
    assert result.returncode == 0, result.stderr
