"""
Set up required stubs on an existing module repository:

  - GH Actions secret  `GH_APP_PRIVATE_KEY`
  - GH Actions variable `GH_APP_ID`
  - Branch ruleset from rulesets/branch_protection.json
  - Tag ruleset from rulesets/tag_protection.json

Reuses the TerraformModulePublisher class from main.py so the behavior stays
identical to what `main.py` does for a brand-new module — just without the
repo-creation, file-copy, and meta-repo submodule steps.

Local usage (from this directory):

    export PAT_TOKEN=...            # or rely on .env
    export GITHUB_ORG=c0x12c
    export GH_APP_ID=...
    export GH_APP_PRIVATE_KEY=...   # PEM content, multiline OK
    python setup_repo.py --repo terraform-aws-msk-kafka-cluster
"""

import argparse
import logging
import os
import sys

from dotenv import load_dotenv

load_dotenv()

# Import after load_dotenv so main.py sees the populated env
from main import TerraformModulePublisher, logger  # noqa: E402

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--repo",
        required=True,
        help="Repository name (no org prefix), e.g. terraform-aws-msk-kafka-cluster",
    )
    parser.add_argument(
        "--skip-secrets",
        action="store_true",
        help="Skip setting GH_APP_PRIVATE_KEY / GH_APP_ID",
    )
    parser.add_argument(
        "--skip-branch-protection",
        action="store_true",
        help="Skip branch ruleset",
    )
    parser.add_argument(
        "--skip-tag-protection",
        action="store_true",
        help="Skip tag ruleset",
    )
    args = parser.parse_args()

    pat_token = os.getenv("PAT_TOKEN")
    org_name = os.getenv("GITHUB_ORG")
    if not pat_token or not org_name:
        logger.error("PAT_TOKEN and GITHUB_ORG must be set (directly or in .env)")
        return 2

    publisher = TerraformModulePublisher(
        github_token=pat_token,
        org_name=org_name,
        base_dir=os.getcwd(),
    )

    try:
        repo = publisher.org.get_repo(args.repo)
    except Exception as exc:
        logger.error(f"Could not fetch repo {org_name}/{args.repo}: {exc}")
        return 1

    logger.info(f"Configuring {repo.full_name}")

    if not args.skip_secrets:
        publisher.setup_github_actions_credentials(repo)
    if not args.skip_branch_protection:
        publisher.setup_branch_protection(repo)
    if not args.skip_tag_protection:
        publisher.setup_tag_protection(repo)

    logger.info(f"Done. {repo.full_name} stubs set up.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
