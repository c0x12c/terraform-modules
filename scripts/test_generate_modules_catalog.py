"""Tests for the catalog description heuristic.

The heuristic picks the Description cell for every row of MODULES.md, so a
change to it silently rewrites the whole catalog. It has already produced
`module "logging_monitor" {`, `<!-- BEGIN_TF_DOCS -->`, `No modules.` and
`source  = "..."` as descriptions; each case below is one of those.
"""
import importlib.util
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location(
    "generate_modules_catalog", ROOT / "configs" / "generate_modules_catalog.py")
catalog = importlib.util.module_from_spec(spec)
sys.modules["generate_modules_catalog"] = catalog
spec.loader.exec_module(catalog)


def describe(tmp_path, monkeypatch, body):
    module = tmp_path / "terraform-aws-example"
    module.mkdir()
    (module / "README.md").write_text(body, encoding="utf-8")
    monkeypatch.setattr(catalog, "ROOT", tmp_path)
    return catalog.description("terraform-aws-example")


@pytest.mark.parametrize("body,expected", [
    ("Creates an example bucket and its policy.\n",
     "Creates an example bucket and its policy."),
    ("# Heading\n\nCreates an example bucket and its policy.\n",
     "Creates an example bucket and its policy."),
    # a fenced usage block must not become the description
    ('## Usage\n\n```hcl\nmodule "main" {\n  source = "x"\n}\n```\n\nCreates a thing here.\n',
     "Creates a thing here."),
    # markdown fences can be tildes, and prose inside one is still code
    ('## Usage\n\n~~~hcl\nThis line looks like prose but is inside a fence\n~~~\n\nCreates a thing here.\n',
     "Creates a thing here."),
    # ... nor an unfenced one: terraform-aws-ses-monitoring has no fences
    ('## Usage\n\nmodule "main" {\n  source  = "registry/x/aws"\n  version = "1.0.0"\n}\n',
     ""),
    # ... nor the inject markers, which open several READMEs
    ("<!-- BEGIN_TF_DOCS -->\n## Requirements\n<!-- END_TF_DOCS -->\n", ""),
    # ... nor terraform-docs' empty-section text, every sentinel of it
    ("<!-- BEGIN_TF_DOCS -->\n## Requirements\n\nNo requirements.\n", ""),
    ("<!-- BEGIN_TF_DOCS -->\n## Providers\n\nNo providers.\n", ""),
    ("<!-- BEGIN_TF_DOCS -->\n## Modules\n\nNo modules.\n", ""),
    ("<!-- BEGIN_TF_DOCS -->\n## Resources\n\nNo resources.\n", ""),
    ("<!-- BEGIN_TF_DOCS -->\n## Inputs\n\nNo inputs.\n", ""),
    ("<!-- BEGIN_TF_DOCS -->\n## Outputs\n\nNo outputs.\n", ""),
    # ... nor a JSON fragment, which reaches here from an unfenced example
    ('## Usage\n\n"<ses-id>": "<ses-identity-id>"\n', ""),
    # list items and tables are structure, not description
    ("- **lake** - the backend collector\n- **ui** - the frontend\n", ""),
    ("1. First do this thing\n2. Then do that thing\n", ""),
    ("| Name | Version |\n|------|---------|\n", ""),
    ("> A blockquote note about the module\n", ""),
    ("![badge](https://example.com/b.svg)\n", ""),
    # too short to be prose
    ("Example module\n", ""),
    # word count, not space count: a double space is still two words
    ("Example  module\n", ""),
    # ... and a tab still separates words
    ("Creates\tan\texample\tbucket\n", "Creates\tan\texample\tbucket"),
])
def test_description(tmp_path, monkeypatch, body, expected):
    assert describe(tmp_path, monkeypatch, body) == expected


def test_long_description_is_truncated(tmp_path, monkeypatch):
    body = "Creates " + "a very long sentence " * 20 + "end.\n"
    got = describe(tmp_path, monkeypatch, body)
    assert len(got) == 110 and got.endswith("...")


def test_missing_readme(tmp_path, monkeypatch):
    monkeypatch.setattr(catalog, "ROOT", tmp_path)
    (tmp_path / "terraform-aws-example").mkdir()
    assert catalog.description("terraform-aws-example") == ""


def test_registry_source():
    assert catalog.registry_source("terraform-aws-rds-cluster") == \
        "terraform.c0x12c.com/c0x12c/rds-cluster/aws"
