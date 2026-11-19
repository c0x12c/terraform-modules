import os
import unittest

from check_pr_body import check

ROOT = os.path.join(os.path.dirname(__file__), "..", "..", "..")
with open(os.path.join(ROOT, ".github", "PULL_REQUEST_TEMPLATE.md"), encoding="utf-8") as f:
    TEMPLATE = f.read()

GOOD = """## What changed

Hosting-only apps get a log-delivery service role.

## Why

The old policy can rewrite any role in the account.

## Modules touched

terraform-aws-amplify: policy chosen by enable_backend.

## Breaking for consumers

No.

## Verification

```text
$ terraform -chdir=terraform-aws-amplify validate
Success! The configuration is valid.
```
"""


class CheckPrBody(unittest.TestCase):
    def test_filled_template_passes(self):
        self.assertEqual(check(TEMPLATE, GOOD), [])

    def test_free_form_body_fails(self):
        errors = check(TEMPLATE, "With enable_backend = false the role gets logs only.\n\nEvidence:\n- it works")
        self.assertTrue(any("missing template sections" in e for e in errors))

    def test_unfilled_template_fails(self):
        errors = check(TEMPLATE, TEMPLATE)
        self.assertTrue(any('section "What changed" is empty' in e for e in errors))
        self.assertTrue(any("Verification" in e for e in errors))

    def test_reordered_sections_fail(self):
        swapped = GOOD.replace("## What changed", "## TMP").replace("## Why", "## What changed").replace("## TMP", "## Why")
        self.assertTrue(any("out of order" in e for e in check(TEMPLATE, swapped)))

    def test_em_dash_fails(self):
        self.assertTrue(any("dash" in e for e in check(TEMPLATE, GOOD.replace("No.", "No \u2014 none."))))

    def test_attribution_fails(self):
        for line in ("Generated with Claude Code", "Co-Authored-By: someone", "\U0001F916 Generated"):
            self.assertTrue(any("attribution" in e for e in check(TEMPLATE, GOOD + "\n" + line + "\n")), line)

    def test_tool_output_mention_is_not_attribution(self):
        body = GOOD.replace("No.", "No. README regenerated with terraform-docs v0.20.0.")
        self.assertEqual(check(TEMPLATE, body), [])

    def test_long_body_fails(self):
        body = GOOD.replace("No.", "No. " + "word " * 400)
        self.assertTrue(any("words outside code blocks" in e for e in check(TEMPLATE, body)))

    def test_code_blocks_do_not_count_toward_length(self):
        body = GOOD.replace("Success!", "Success! " + "line\n" * 500)
        self.assertEqual(check(TEMPLATE, body), [])

    def test_text_left_inside_comments_does_not_count(self):
        body = GOOD.replace("No.", "<!-- notes -->\n")
        self.assertTrue(any('section "Breaking for consumers" is empty' in e for e in check(TEMPLATE, body)))


if __name__ == "__main__":
    unittest.main()
