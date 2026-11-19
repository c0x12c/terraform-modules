#!/usr/bin/env python3
"""Fail a pull request whose body does not follow .github/PULL_REQUEST_TEMPLATE.md.

Usage: check_pr_body.py <template> <body-file>
"""
import re
import sys

MAX_PROSE_WORDS = 300
BANNED_DASHES = re.compile("[\u2013\u2014\u2015]")
ATTRIBUTION = re.compile(r"generated with|co-authored-by|\U0001F916", re.IGNORECASE)
COMMENT = re.compile(r"<!--.*?-->", re.DOTALL)
FENCE = re.compile(r"```[^\n]*\n(.*?)```", re.DOTALL)
HEADING = re.compile(r"^## +(.+?)\s*$", re.MULTILINE)


def sections(text):
    marks = list(HEADING.finditer(text))
    return [
        (m.group(1), text[m.end(): marks[i + 1].start() if i + 1 < len(marks) else len(text)])
        for i, m in enumerate(marks)
    ]


def check(template, body):
    errors = []
    required = [name for name, _ in sections(COMMENT.sub("", template))]
    body = COMMENT.sub("", body.replace("\r\n", "\n"))
    found = sections(body)
    names = [name for name, _ in found]

    missing = [name for name in required if name not in names]
    if missing:
        errors.append("missing template sections: " + ", ".join(missing))
    elif [n for n in names if n in required] != required:
        errors.append("template sections are out of order; expected: " + ", ".join(required))

    for name, content in found:
        if name in required and not content.strip():
            errors.append(f'section "{name}" is empty; write "none" if it does not apply')

    verification = dict(found).get("Verification", "")
    if "Verification" in required and not any(b.strip() for b in FENCE.findall(verification)):
        errors.append('"Verification" needs a code block with the commands run and their output')

    if BANNED_DASHES.search(body):
        errors.append("contains an en-dash, em-dash or horizontal bar; use a plain hyphen")
    if ATTRIBUTION.search(body):
        errors.append("contains AI or tool attribution (generated-with line, co-author trailer or robot emoji)")

    prose = len(FENCE.sub("", body).split())
    if prose > MAX_PROSE_WORDS:
        errors.append(f"{prose} words outside code blocks; the limit is {MAX_PROSE_WORDS}")
    return errors


def main():
    template, body_file = sys.argv[1], sys.argv[2]
    with open(template, encoding="utf-8") as f:
        tpl = f.read()
    with open(body_file, encoding="utf-8") as f:
        body = f.read()
    errors = check(tpl, body)
    for e in errors:
        print(f"::error title=PR body::{e}")
    if errors:
        print("Rules: AGENTS.md, section 'Pull requests'. Edit the PR description; this check re-runs on edit.")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
