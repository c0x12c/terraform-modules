import subprocess
import sys
import unittest
from pathlib import Path


class ClassifyVersionsTests(unittest.TestCase):
    def assert_classification(self, text, expected):
        result = subprocess.run(
            [sys.executable, str(Path(__file__).with_name("classify_versions.py"))],
            input=text,
            text=True,
            capture_output=True,
            check=True,
        )
        self.assertEqual(result.stdout, expected + "\n")

    def test_boto3_constraint_patch(self):
        self.assert_classification(
            "chore(deps): update boto3 requirement from <2,>=1.43.103 to >=1.43.121,<2 in /tools/registry in the pip group",
            "non-major",
        )

    def test_dotenv_patch(self):
        self.assert_classification(
            "chore(deps): bump python-dotenv from 1.2.3 to 1.2.4 in /set-up-repositories in the pip group",
            "non-major",
        )

    def test_checkout_major(self):
        self.assert_classification(
            "chore(deps): bump actions/checkout from 6 to 7 in the actions group",
            "major bump",
        )

    def test_zero_major_minor(self):
        self.assert_classification(
            "chore(deps): bump c0x12c/gh-actions-slack-notify from 0.5.0 to 0.6.0 in the actions group",
            "major bump",
        )

    def test_boto3_constraint_major(self):
        self.assert_classification(
            "chore(deps): update boto3 requirement from <2,>=1.43 to >=2.0.1,<3 in /tools/registry",
            "major bump",
        )

    def test_no_versions(self):
        self.assert_classification(
            "chore(deps): something without versions", "no parseable versions"
        )

    def test_body_major(self):
        self.assert_classification(
            "chore(deps): bump python-dotenv from 1.2.3 to 1.2.4 in /set-up-repositories in the pip group\nBumps x from 1.0 to 2.0",
            "major bump",
        )

    def test_body_prose_ignored(self):
        self.assert_classification(
            "chore(deps): bump python-dotenv from 1.2.3 to 1.2.4 in /set-up-repositories in the pip group\n- Fix moving from 1 to 9 workers",
            "non-major",
        )


if __name__ == "__main__":
    unittest.main()
