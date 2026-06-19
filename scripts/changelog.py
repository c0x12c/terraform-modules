"""Utilities for splitting module changelogs into per-version sections."""

from __future__ import annotations

import re


VERSION_HEADER_RE = re.compile(
    r"^##\s+\[v?(\d+\.\d+\.\d+[^\]]*)\].*$",
    re.MULTILINE,
)


def _trim_blank_lines(text: str) -> str:
    lines = text.splitlines(keepends=True)
    start = 0
    end = len(lines)
    while start < end and not lines[start].strip():
        start += 1
    while end > start and not lines[end - 1].strip():
        end -= 1
    return "".join(lines[start:end])


def split_changelog(text: str) -> dict[str, str]:
    """Map bare version -> raw markdown section."""
    matches = list(VERSION_HEADER_RE.finditer(text))
    if not matches:
        return {}

    sections: dict[str, str] = {}
    for index, match in enumerate(matches):
        start = match.start()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        version = match.group(1).lstrip("v")
        sections[version] = _trim_blank_lines(text[start:end])
    return sections
