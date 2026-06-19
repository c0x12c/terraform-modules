from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent))

from changelog import split_changelog


REPO_ROOT = Path(__file__).resolve().parents[1]
ARGOCD_CHANGELOG = REPO_ROOT / "terraform-aws-helm-argocd" / "CHANGELOG.md"
SERVICE_BOT_CHANGELOG = REPO_ROOT / "terraform-aws-helm-service-bot" / "CHANGELOG.md"


def test_split_changelog_empty_input_returns_empty_dict():
    assert split_changelog("") == {}
    assert split_changelog("# Changelog\n\nNo releases yet.\n") == {}


def test_split_changelog_returns_all_argocd_versions():
    sections = split_changelog(ARGOCD_CHANGELOG.read_text(encoding="utf-8"))

    expected_versions = {
        "1.4.2",
        "1.4.1",
        "1.4.0",
        "1.3.0",
        "1.2.2",
        "1.2.1",
        "1.2.0",
        "1.0.2",
        "1.0.1",
        "1.0.0",
        "0.4.4",
        "0.4.3",
        "0.4.2",
        "0.3.15",
        "0.3.12",
        "0.3.8",
        "0.3.6",
        "0.3.5",
        "0.3.3",
        "0.3.2",
    }
    assert set(sections) == expected_versions


def test_split_changelog_preserves_multi_paragraph_sections():
    section = split_changelog(ARGOCD_CHANGELOG.read_text(encoding="utf-8"))["1.4.2"]

    assert "The 1.4.1 fix alone was not enough" in section
    assert "Trade-off: a recreate momentarily removes the AppProject (~1 s)." in section


def test_split_changelog_preserves_breaking_changes_heading():
    section = split_changelog(ARGOCD_CHANGELOG.read_text(encoding="utf-8"))["1.2.0"]

    assert "### ⚠ BREAKING CHANGES" in section


def test_split_changelog_preserves_fenced_code_blocks():
    section = split_changelog(ARGOCD_CHANGELOG.read_text(encoding="utf-8"))["0.3.5"]

    assert "```hcl" in section
    assert "  wait  = true" in section
    assert "timeout = 300" in section
    assert "```" in section


def test_split_changelog_preserves_nested_bullets():
    section = split_changelog(ARGOCD_CHANGELOG.read_text(encoding="utf-8"))["0.4.2"]

    assert "assumeRoles -> assume_role" in section
    assert "* `var.external_cluster`" in section


def test_split_changelog_has_clean_section_boundaries():
    sections = split_changelog(ARGOCD_CHANGELOG.read_text(encoding="utf-8"))

    assert "The 1.4.1 fix alone was not enough" in sections["1.4.2"]
    assert "Force-conflicts on server-side apply preserves the original goal" not in sections[
        "1.4.2"
    ]


def test_split_changelog_parses_headers_with_compare_urls():
    sections = split_changelog(SERVICE_BOT_CHANGELOG.read_text(encoding="utf-8"))

    assert "0.7.0" in sections
    assert sections["0.7.0"].startswith("## [0.7.0](")
