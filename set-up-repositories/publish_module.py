"""
Publish a single Terraform module to the Terraform public registry.

Standalone entrypoint so the same code runs locally and in CI. Only performs
the Terraform Cloud registry VCS-publish call — it does NOT create the GitHub
repo, set protection rules, or copy any files.

Local usage:

    export TF_API_TOKEN=...                 # TFC user/team token
    export TF_GH_APP_INSTALLATION_ID=...    # TFC GitHub App installation id
    export GITHUB_ORG=c0x12c                # namespace on registry.terraform.io
    python publish_module.py --module-name terraform-aws-msk-kafka-cluster

Add --dry-run to print the request without sending it.
"""

import argparse
import logging
import os
import re
import sys

import requests
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
logger = logging.getLogger(__name__)

MODULE_NAME_RE = re.compile(r"^terraform-([a-z0-9]+)-(.+)$")


def parse_module_name(module_name: str) -> tuple[str, str]:
    match = MODULE_NAME_RE.match(module_name)
    if not match:
        raise ValueError(
            f"Module name must match 'terraform-<provider>-<name>', got '{module_name}'"
        )
    return match.group(1), match.group(2)


def is_module_published(org: str, name: str, provider: str) -> bool:
    url = f"https://registry.terraform.io/v1/modules/{org}/{name}/{provider}"
    response = requests.get(url, timeout=30)
    if response.status_code == 200:
        return True
    if response.status_code == 404:
        return False
    raise RuntimeError(
        f"Unexpected status {response.status_code} from registry check: {response.text}"
    )


def publish(org: str, module_name: str, tf_api_token: str, gh_app_installation_id: str) -> None:
    url = f"https://app.terraform.io/api/v2/organizations/{org}/registry/modules"
    payload = {
        "data": {
            "attributes": {
                "vcs_repo": {
                    "identifier": f"{org}/{module_name}",
                    "github_app_installation_id": gh_app_installation_id,
                }
            },
            "organization_name": org,
        }
    }
    headers = {
        "Content-Type": "application/vnd.api+json",
        "Authorization": f"Bearer {tf_api_token}",
    }
    logger.info(f"POST {url}  identifier={org}/{module_name}")
    response = requests.post(url, headers=headers, json=payload, timeout=60)

    if response.status_code == 201:
        logger.info("Module successfully published.")
        return
    if response.status_code == 422:
        raise RuntimeError(
            f"Validation failed (422). Typical causes: no semver tags yet, "
            f"or VCS connection mismatch. Details: {response.text}"
        )
    if response.status_code == 401:
        raise RuntimeError("Unauthorized (401): TF_API_TOKEN is invalid or lacks scope.")
    raise RuntimeError(f"Publish failed with {response.status_code}: {response.text}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--module-name",
        required=True,
        help="Submodule repo name, e.g. terraform-aws-msk-kafka-cluster",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the request body and exit without calling the API",
    )
    args = parser.parse_args()

    org = os.getenv("GITHUB_ORG")
    tf_api_token = os.getenv("TF_API_TOKEN")
    gh_app_installation_id = os.getenv("TF_GH_APP_INSTALLATION_ID")

    missing = [
        name
        for name, value in {
            "GITHUB_ORG": org,
            "TF_API_TOKEN": tf_api_token,
            "TF_GH_APP_INSTALLATION_ID": gh_app_installation_id,
        }.items()
        if not value
    ]
    if missing and not args.dry_run:
        logger.error(f"Missing required environment variables: {', '.join(missing)}")
        return 2

    provider, short_name = parse_module_name(args.module_name)
    registry_url = (
        f"https://registry.terraform.io/modules/{org}/{short_name}/{provider}/latest"
    )
    logger.info(
        f"Target: namespace={org} provider={provider} name={short_name}  ->  {registry_url}"
    )

    if args.dry_run:
        logger.info("[dry-run] skipping network calls")
        return 0

    if is_module_published(org=org, name=short_name, provider=provider):
        logger.info(f"Already published at {registry_url} — nothing to do.")
        return 0

    publish(
        org=org,
        module_name=args.module_name,
        tf_api_token=tf_api_token,
        gh_app_installation_id=gh_app_installation_id,
    )
    logger.info(f"Done. Registry page: {registry_url}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
