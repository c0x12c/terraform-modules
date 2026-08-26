from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).parent))

from changelog import split_changelog


REPO_ROOT = Path(__file__).resolve().parents[1]
ARGOCD_CHANGELOG = REPO_ROOT / "terraform-aws-helm-argocd" / "CHANGELOG.md"
SERVICE_BOT_CHANGELOG = REPO_ROOT / "terraform-aws-helm-service-bot" / "CHANGELOG.md"


def test_split_changelog_empty_input_returns_empty_dict():
    assert split_changelog("") == {}
    assert split_changelog("# Changelog\n\nNo releases yet.\n") == {}


def test_split_changelog_returns_every_versioned_heading():
    text = ARGOCD_CHANGELOG.read_text(encoding="utf-8")

    sections = split_changelog(text)

    # Derived from the file, not frozen. This changelog gains an entry on every
    # release, so a hardcoded set rots into a false failure the moment a module
    # ships - which is exactly what happened while nothing ran these tests.
    # Same version grammar as the parser, including any prerelease suffix - a
    # narrower pattern here would capture "1.2.3" where split_changelog keys
    # "1.2.3-rc.1" and fail for a reason that has nothing to do with the parser.
    # Still an independent derivation: this finds headings, the parser also has to
    # slice and key the sections between them, which is what the comparison checks.
    headings = re.findall(r"^##\s+\[v?(\d+\.\d+\.\d+[^\]]*)\]", text, re.MULTILINE)
    assert headings, "no version headings found - the changelog format changed"
    assert set(sections) == set(headings)
    # Keyed by version, so a version that appears twice in the changelog collapses
    # to one entry and the earlier section is lost. The argocd changelog does this
    # for 1.4.0 and 1.4.1. Asserting against the UNIQUE set records that behaviour
    # rather than pretending each heading survives.
    assert len(sections) == len(set(headings))
    # Anchors that must survive whatever the newest release is.
    assert {"0.3.2", "1.0.0", "1.4.2"}.issubset(sections)


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
