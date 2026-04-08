import argparse
import datetime
import json
import logging
import os
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import List

import git
import jwt
import requests
from dotenv import load_dotenv
from git import Repo
from github import Github, GithubException
from openai import OpenAI

load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

GH_APP_ID = os.getenv("GH_APP_ID")
GH_APP_INSTALLATION_ID = os.getenv("GH_APP_INSTALLATION_ID")
GH_APP_PRIVATE_KEY = os.getenv("GH_APP_PRIVATE_KEY")
GITHUB_ORG = os.getenv("GITHUB_ORG")
TF_GH_APP_INSTALLATION_ID = os.getenv("TF_GH_APP_INSTALLATION_ID")
PAT_TOKEN = os.getenv("PAT_TOKEN")

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

X_CSRF_TOKEN = os.getenv("X_CSRF_TOKEN")
TF_API_TOKEN = os.getenv("TF_API_TOKEN")

client = OpenAI(
    api_key=OPENAI_API_KEY
)

if not PAT_TOKEN:
    raise EnvironmentError("The 'PAT_TOKEN' environment variable is not set.")

CONFIG = {
    "update_repo_content": False,
    "enable_branch_protection": True,
    "enable_tag_protection": True,
    "setup_actions_secrets": True,
    "trigger_release_workflow": False,
    "enabled_publishing": True,
    "skip_published_modules": False,
    "add_module_to_meta_repo": True,
}


class TerraformModulePublisher:
    def __init__(
            self, github_token: str, org_name: str, base_dir: str
    ):
        self.github_token = github_token
        self.github_client = Github(github_token)
        self.provider_folders = ['aws', 'datadog', 'gcp', 'github']
        self.base_dir = base_dir
        self.org_name = org_name

        # Get organization
        try:
            self.org = self.github_client.get_organization(org_name)
            logger.info(f"Successfully connected to organization: {org_name}")
        except GithubException as e:
            logger.error(f"Failed to access organization {org_name}: {str(e)}")
            raise

        # Cache for checking repositories
        self._org_repos = None

    def _get_org_repos(self) -> set:
        """Cache and return organization's repositories names"""
        if self._org_repos is None:
            self._org_repos = {repo.name for repo in self.org.get_repos()}
        return self._org_repos

    def repository_exists(self, repo_name: str) -> bool:
        """Check if repository already exists"""
        return repo_name in self._get_org_repos()

    def create_github_repo(self, repo_name):
        """Create a new GitHub repository with specific settings"""
        try:
            logger.info(f"Attempting to create repository '{repo_name}' in organization '{self.org.login}'.")

            repo = self.org.create_repo(
                name=repo_name,
                private=False,
                auto_init=True,
                license_template="apache-2.0"
            )

            # Update repository settings
            repo.edit(
                allow_squash_merge=True,
                use_squash_pr_title_as_default=True,
                squash_merge_commit_title='PR_TITLE',
                allow_merge_commit=False,
                allow_rebase_merge=False,
                delete_branch_on_merge=True,
            )

            return repo
        except Exception as e:
            logger.error(f"Error creating repository {repo_name}: {str(e)}", exc_info=True)
            raise

    def setup_branch_protection(self, repo, protection_rules_file='branch_protection.json'):
        """Setup branch protection rules from JSON file"""
        try:
            rulesets_dir = os.path.join(os.getcwd(), 'rulesets')
            protection_rules_path = os.path.join(rulesets_dir, protection_rules_file)

            if os.path.exists(protection_rules_path):
                with open(protection_rules_path, 'r') as f:
                    rules = json.load(f)

                headers = {
                    "Authorization": f"Bearer {self.github_token}",
                    "Accept": "application/vnd.github+json"
                }

                # Make the API request to create the ruleset
                api_url = f"https://api.github.com/repos/{self.org_name}/{repo.name}/rulesets"

                # Step 1: Check if any rulesets exist
                get_response = requests.get(api_url, headers=headers)
                existing_rulesets = get_response.json()
                ruleset_id = None

                if get_response.status_code == 200:
                    # Step 2: Look for existing rulesets matching the policy name in the payload
                    for ruleset in existing_rulesets:
                        if ruleset.get("name") == rules.get("name"):
                            ruleset_id = ruleset.get("id")
                            break

                if ruleset_id is None:
                    response = requests.post(api_url, headers=headers, json=rules)
                    logger.info(f"Branch protection rules creation response: {response.text}")
                else:
                    response = requests.put(f"{api_url}/{ruleset_id}", headers=headers, json=rules)
                    logger.info(f"Branch protection rules updating response: {response.text}")

                logger.info(f"Branch protection rules applied for {repo.name}")
            else:
                logger.warning(f"Branch protection file '{protection_rules_path}' does not exist.")
        except Exception as e:
            logger.error(f"Error setting up branch protection: {str(e)}", exc_info=True)

    def setup_tag_protection(self, repo, tag_rules_file='tag_protection.json'):
        """Setup tag protection rules from JSON file"""
        try:
            rulesets_dir = os.path.join(os.getcwd(), 'rulesets')
            tag_rules_path = os.path.join(rulesets_dir, tag_rules_file)

            if os.path.exists(tag_rules_path):
                with open(tag_rules_path, 'r') as f:
                    rules = json.load(f)

                headers = {
                    "Authorization": f"Bearer {self.github_token}",
                    "Accept": "application/vnd.github+json"
                }

                # Make the API request to create the ruleset
                api_url = f"https://api.github.com/repos/{self.org_name}/{repo.name}/rulesets"

                # Step 1: Check if any rulesets exist
                get_response = requests.get(api_url, headers=headers)
                existing_rulesets = get_response.json()
                ruleset_id = None

                if get_response.status_code == 200:
                    # Step 2: Look for existing rulesets matching the policy name in the payload
                    for ruleset in existing_rulesets:
                        if ruleset.get("name") == rules.get("name"):
                            ruleset_id = ruleset.get("id")
                            break

                if ruleset_id is None:
                    response = requests.post(api_url, headers=headers, json=rules)
                    logger.info(f"Tag protection rules creation response: {response.text}")
                else:
                    response = requests.put(f"{api_url}/{ruleset_id}", headers=headers, json=rules)
                    logger.info(f"Tag protection rules updating response: {response.text}")

                logger.info(f"Tag protection rules response: {response.text}")
                logger.info(f"Tag protection rules applied for {repo.name}")
            else:
                logger.warning(f"Tag protection file '{tag_rules_path}' does not exist.")
        except Exception as e:
            logger.error(f"Error setting up tag protection: {str(e)}", exc_info=True)

    def setup_github_actions_credentials(self, repo):
        logger.info(f"Setting up GitHub Actions credentials for repository: {repo.name}")

        gh_app_private_key = _get_github_app_private_key()

        repo.create_secret(secret_name="GH_APP_PRIVATE_KEY", unencrypted_value=gh_app_private_key)
        logger.info("Secret 'GH_APP_PRIVATE_KEY' successfully created.")

        # ----- Step 2: Set up the variable `GH_APP_ID` -----
        try:
            # Get the list of existing variables to check if the variable already exists
            existing_variables = repo.get_variables()
            existing_variable = next((var for var in existing_variables if var.name == "GH_APP_ID"), None)

            if existing_variable and existing_variable != GH_APP_ID:
                repo.delete_variable(variable_name="GH_APP_ID")
                repo.create_variable(variable_name="GH_APP_ID", value=GH_APP_ID)
                logger.info("Variable 'GH_APP_ID' successfully recreated due to value mismatch.")
            else:
                repo.create_variable(variable_name="GH_APP_ID", value=GH_APP_ID)
                logger.info("Variable 'GH_APP_ID' successfully created.")

            # Create the variable (either fresh or after deletion)
        except Exception as e:
            logger.error(f"Error setting the variable 'GH_APP_ID': {e}", exc_info=True)

    def trigger_release_workflow(self, repo):
        logger.info(f"Triggering 'Release' workflow for repository: {repo.name}")

        # Endpoint to fetch the repository tags
        tags_url = f"https://api.github.com/repos/{self.org_name}/{repo.name}/tags"

        # Fetch tags (no authorization needed for public repositories)
        response = requests.get(tags_url)

        # Handle the response for fetching tags
        if response.status_code == 200:  # 200 means success
            tags = response.json()
            if tags:  # If there are any existing tags, skip triggering the workflow
                logger.info(f"Skipping 'Release' workflow trigger for repository: {repo.name} as tags already exist.")
                return
            else:
                logger.info(f"No tags found for repository: {repo.name}, proceeding to trigger 'Release' workflow.")
        else:
            logger.error(
                f"Failed to fetch tags for repository: {repo.name}. "
                f"Status Code: {response.status_code}, Response: {response.text}"
            )
            return

        # Workflow file name to trigger
        workflow_file_name = "release.yml"

        # Define the dispatch endpoint
        dispatch_url = f"https://api.github.com/repos/{self.org_name}/{repo.name}/actions/workflows/{workflow_file_name}/dispatches"

        # Data payload for workflow dispatch
        payload = {
            "ref": "master"
        }

        # Headers for the API call
        headers = {
            "Authorization": f"token {self.github_token}",  # Use the token provided in the class
            "Accept": "application/vnd.github+json"
        }

        # Make the POST request to trigger the workflow
        response = requests.post(dispatch_url, headers=headers, json=payload)

        # Handle the response
        if response.status_code == 204:  # 204 means success with no content
            logger.info(f"Successfully triggered 'Release' workflow for repository: {repo.name}")
        else:
            logger.error(
                f"Failed to trigger 'Release' workflow for repository: {repo.name}. "
                f"Status Code: {response.status_code}, Response: {response.text}"
            )

    def is_module_published(self, module_name, namespace, provider):
        try:
            # Terraform public registry base URL for searching modules
            api_url = f"https://registry.terraform.io/v1/modules/{namespace}/{module_name}/{provider}"

            response = requests.get(api_url)

            logger.info(
                f"Check module publication status for {namespace}/{module_name}/{provider} using url: {api_url} - response: {response.status_code}")

            # If response code is 200, the module exists
            if response.status_code == 200:
                logger.info(
                    f"Module '{namespace}/{module_name}/{provider}' is published in the Terraform public registry.")
                return True
            elif response.status_code == 404:
                logger.info(
                    f"Module '{namespace}/{module_name}/{provider}' is not published in the Terraform public registry.")
                return False
            else:
                logger.error(f"Unexpected status code {response.status_code} received from Terraform registry.")
                return False

        except requests.RequestException as e:
            logger.error(f"An error occurred while checking the module's publication status: {e}", exc_info=True)
            return False

    def publish_to_terraform_public_registry(self, repo):
        headers = {
            "Content-Type": "application/vnd.api+json",
            "x-csrf-token": X_CSRF_TOKEN,
            "Authorization": f"Bearer {TF_API_TOKEN}"
        }

        parts = repo.name.split("-")
        provider = parts[1]
        module_name = "-".join(parts[2:])

        # Check if the module is already published to the Terraform public registry
        if self.is_module_published(module_name=module_name, namespace=self.org_name, provider=provider):
            logger.info(
                f"Module '{module_name}' is already published to the Terraform public registry. Skipping publish.")
            return

        registry_url = f"https://app.terraform.io/api/v2/organizations/{self.org_name}/registry/modules"

        # Construct the request payload
        payload = {
            "data": {
                "attributes": {
                    "vcs_repo": {
                        "identifier": f"{self.org_name}/{repo.name}",
                        "github_app_installation_id": TF_GH_APP_INSTALLATION_ID,
                    }
                },
                "organization_name": self.org_name
            }
        }

        try:
            logger.info(
                f"Publishing module to Terraform Cloud Public Registry using repo: {repo.name} with url: {registry_url}")
            response = requests.post(registry_url, headers=headers, json=payload)

            if response.status_code == 201:  # HTTP 201 Created
                logger.info("Module successfully published to the Terraform Cloud registry.")
                return True
            elif response.status_code == 422:  # HTTP 422 Unprocessable Entity
                logger.error("Module is already published or validation failed.")
                logger.error(f"Details: {response.text}")
            elif response.status_code == 401:  # HTTP 401 Unauthorized
                logger.error("Invalid Terraform Cloud API token.")
            else:
                logger.error(f"Failed to publish module. Response: {response.text}")
        except Exception as e:
            logger.error(f"An error occurred while publishing to Terraform Cloud: {e}", exc_info=True)

        return False

    def add_repos_as_submodules_and_create_pr(self, repos):
        """
        Adds the given repositories as submodules to the meta-repo defined in the `META_REPO_URL` environment
        and creates a pull request for the changes.

        :param repos: A list of repository URLs (e.g., ["https://github.com/org/repo1.git", "https://github.com/org/repo2.git"]).
        """
        # Retrieve the meta-repo GitHub URL from the environment variable
        meta_repo_url = os.getenv("META_REPO_URL")
        if not meta_repo_url:
            logger.error(
                "Environment variable 'META_REPO_URL' is not set. Please set it to the GitHub URL of the meta-repo.")
            return

        # Check if the meta-repo already exists locally
        meta_repo = _get_meta_repo(meta_repo_url=meta_repo_url)
        meta_repo_path = meta_repo.working_dir
        logger.info(f"Meta-repo path: {meta_repo_path}")

        # Extract meta-repo name and org name from the URL
        org_name, meta_repo_name = self._parse_meta_repo_url(meta_repo_url)

        # Navigate to the meta-repo directory
        original_cwd = os.getcwd()
        os.chdir(meta_repo_path)

        for repo in repos:
            try:
                repo_name = repo.name

                # Check if the submodule already exists
                if os.path.exists(os.path.join(meta_repo_path, repo_name)):
                    logger.info(f"Repository '{repo_name}' already exists as a submodule. Skipping.")
                    continue

                # Create a feature branch for adding the current submodule
                feature_branch = f"add-terraform-submodule-{repo_name}"
                logger.info(f"Creating feature branch '{feature_branch}' for module '{repo_name}'...")
                meta_repo.git.checkout('-b', feature_branch)

                # Add the repository as a submodule
                logger.info(f"Adding '{repo_name}' as a submodule...")
                meta_repo.git.submodule("add", "-b", "master", repo.ssh_url)

                # Check if there are changes in the working tree
                logger.info("Checking for changes before committing...")
                # status_output = subprocess.run(
                #     ["git", "status", "--porcelain"],
                #     stdout=subprocess.PIPE,
                #     text=True
                # ).stdout.strip()

                status_output = meta_repo.git.status("--porcelain").strip()

                if not status_output:
                    logger.info("No changes detected in the repository. Skipping commit and PR creation.")
                    continue

                # Stage, commit, and push the changes
                logger.info("Staging changes for submodules...")
                meta_repo.git.add(A=True)
                # subprocess.run(["git", "add", "."], check=True)  # Add all changes
                commit_message = f"Add Terraform module `{repo_name}` as submodule"
                logger.info(f"Committing changes: '{commit_message}'...")
                meta_repo.git.commit("-m", commit_message)
                # subprocess.run(["git", "commit", "-m", commit_message], check=True)

                # logger.info("Debugging...")
                # subprocess.run(["git", "remote", "-v"], check=True)

                logger.info("Pushing feature branch...")
                # subprocess.run(["git", "push", "-u", "origin", feature_branch, "-f"], check=True)
                meta_repo.git.push("--force", "origin", feature_branch)

                # Create a pull request using the GitHub API
                pr_title = f"Add Terraform module `{repo_name}` as submodule"
                pr_body = f"This pull request adds Terraform module `{repo_name}` submodule to the repository."
                logger.info(f"Creating a pull request titled '{pr_title} in {org_name} Org'...")
                pr_id = self.create_pull_request(org_name, meta_repo_name, feature_branch, pr_title, pr_body)

                # Attempt to auto-merge the pull request
                try:
                    logger.info(f"Attempting to auto-merge the pull request for branch '{feature_branch}'...")
                    self.auto_merge_pull_request(
                        org_name=org_name,
                        repo_name=meta_repo_name,
                        pr_id=pr_id
                    )
                except Exception as e:
                    logger.error(f"Auto-merge failed: {e}")

            except subprocess.CalledProcessError as e:
                logger.error(f"Error occurred during submodule addition or PR creation: {e}")
            finally:
                # Navigate back to the original directory and clean up
                os.chdir(original_cwd)

    def auto_merge_pull_request(self, org_name, repo_name, pr_id):
        """
        Automatically merges a pull request on GitHub if the checks have passed.

        :param org_name: The GitHub organization name.
        :param repo_name: The name of the repository containing the pull request.
        :param pr_id: The ID of the pull request to be merged.
        """
        pr_url = f"https://api.github.com/repos/{org_name}/{repo_name}/pulls"
        headers = {
            "Authorization": f"token {self.github_token}",
            "Accept": "application/vnd.github+json",
        }

        # Attempt to merge the pull request
        merge_url = f"{pr_url}/{pr_id}/merge"
        payload = {"merge_method": "squash"}
        logger.info(f"Attempting to merge pull request #{merge_url}, payload=[{payload}]...")
        merge_response = requests.put(merge_url, json=payload, headers=headers)

        if merge_response.status_code == 200:
            logger.info(f"Pull request #{pr_id} merged successfully.")
        else:
            logger.error(f"Failed to merge pull request #{pr_id}. "
                         f"Status Code: {merge_response.status_code}, Response: {merge_response.text}")
            raise Exception(f"Failed to merge pull request #{pr_id}.")

    def _parse_meta_repo_url(self, meta_repo_url):
        """
        Parses the organization name and repository name from the META_REPO_URL.

        :param meta_repo_url: The GitHub URL of the meta-repo (e.g., "git@github.com:org-name/repo-name.git" or "https://github.com/org-name/repo-name").
        :return: (org_name, repo_name) as a tuple.
        """
        try:
            logger.info(f"Parsing organization and repository name from META_REPO_URL: {meta_repo_url}")

            # Handle HTTPS URL format: https://github.com/org-name/repo-name.git
            if meta_repo_url.startswith("https://"):
                # Remove protocol and domain, split by '/'
                path = meta_repo_url.replace("https://github.com/", "")
                repo_parts = path.split("/")
                org_name = repo_parts[0]
                repo_name = repo_parts[1].replace(".git", "")
            # Handle SSH URL format: git@github.com:org-name/repo-name.git
            else:
                repo_parts = meta_repo_url.split(":")[-1].split("/")
                org_name = repo_parts[0]
                repo_name = repo_parts[1].replace(".git", "")

            return org_name, repo_name
        except Exception:
            logger.error(f"Failed to parse organization and repo name from META_REPO_URL: {meta_repo_url}")
            raise

    def create_pull_request(self, org_name, repo_name, branch, title, body):
        """
        Creates a pull request on GitHub using the GitHub API.

        :param org_name: The GitHub organization name.
        :param repo_name: The name of the repository where the PR will be created.
        :param branch: The feature branch to merge into the default branch (e.g., 'main').
        :param title: The title of the pull request.
        :param body: The body/description of the pull request.
        """
        pr_url = f"https://api.github.com/repos/{org_name}/{repo_name}/pulls"
        headers = {
            "Authorization": f"token {self.github_token}",
            "Accept": "application/vnd.github+json",
        }
        payload = {
            "title": title,
            "body": body,
            "head": branch,
            "base": "master"
        }

        response = requests.post(pr_url, json=payload, headers=headers)
        if response.status_code == 201:
            response_content = response.json()
            pull_request_url = response_content.get('html_url')
            pull_request_id = response_content.get('number')
            logger.info(f"Pull request created successfully: {pull_request_url}")
            return pull_request_id
        else:
            logger.error(
                f"Failed to create pull request. "
                f"Status Code: {response.status_code}, Response: {response.text}"
            )

    def process_module(self, provider: str, module_name: str, module_path: str) -> dict:
        """Process a single Terraform module"""
        repo_name = f"terraform-{provider}-{module_name}"
        logger.info(f"Processing module: {repo_name}")

        result = {
            'provider': provider,
            'module': module_name,
            'repo_name': repo_name,
            'status': 'skipped',
            'message': ''
        }

        try:
            if (CONFIG['skip_published_modules']
                    and self.is_module_published(
                        namespace=self.org_name,
                        provider=provider,
                        module_name=module_name
                    )
            ):
                logger.info(f"Skipping module {module_name}: Already published in the Terraform public registry.")
                result.update({
                    'status': 'skipped',
                    'message': 'Module has already been published'
                })
                return result

            if self.repository_exists(repo_name):
                repo = self.org.get_repo(name=repo_name)
            else:
                repo = self.create_github_repo(repo_name)

            if CONFIG["update_repo_content"]:
                with tempfile.TemporaryDirectory() as temp_dir:
                    # Clone the new repository
                    repo_path = os.path.join(temp_dir, repo_name)

                    if os.path.exists(repo_path):
                        shutil.rmtree(repo_path)

                    logger.info(f"Clone repository {repo_name} to {repo_path} using url: {repo.url}")

                    cloned_url = repo.html_url.replace("https://", f"https://{self.github_token}@") + ".git"
                    repo_clone = Repo.clone_from(cloned_url, repo_path)

                    # Copy module files
                    self.copy_module_files(module_path, repo_path)

                    # Check for changes before committing
                    if repo_clone.is_dirty(untracked_files=True):
                        print(f"Changes detected in repository {repo_name}. Pushing changes to GitHub.")
                        repo_clone.git.add(A=True)

                        # Check if the repository has any commits
                        if len(list(repo_clone.iter_commits())) == 0:
                            commit_subject = "Initial commit"
                        else:
                            repo_diff = repo_clone.git.diff('HEAD')

                            if len(repo_diff) > 1000:
                                commit_subject = "Initialize project with core functionalities"
                                logger.info("Diff length is large. Using default commit subject.")
                            else:
                                commit_subject = self.generate_commit_subject(diff=repo_diff)

                        repo_clone.index.commit(commit_subject)
                        repo_clone.git.push('origin', 'master')
                    else:
                        logger.info("No changes detected. Skipping commit and push.")

            # Setup protection rules
            if CONFIG["enable_branch_protection"]:
                self.setup_branch_protection(repo)

            if CONFIG["enable_tag_protection"]:
                self.setup_tag_protection(repo)

            if CONFIG["setup_actions_secrets"]:
                self.setup_github_actions_credentials(repo)

            if CONFIG["trigger_release_workflow"]:
                self.trigger_release_workflow(repo)

            if CONFIG["enabled_publishing"]:
                self.publish_to_terraform_public_registry(repo=repo)

            if CONFIG["add_module_to_meta_repo"]:
                self.add_repos_as_submodules_and_create_pr(repos=[repo])

            logger.info(f"Successfully processed module: {repo_name}")
            result.update({
                'status': 'success',
                'repo_url': repo.html_url,
                'message': 'Successfully created and configured repository'
            })

        except GithubException as e:
            message = f"GitHub API error processing module: {str(e)}"
            logger.error(message)
            result.update({
                'status': 'error',
                'message': message
            })
        except git.GitError as e:
            message = f"Git error processing module: {str(e)}"
            logger.error(message)
            result.update({
                'status': 'error',
                'message': message
            })
        except IOError as e:
            message = f"IO error processing module: {str(e)}"
            logger.error(message)
            result.update({
                'status': 'error',
                'message': message
            })

        return result

    def generate_commit_subject(self, diff: str):
        try:
            # Generate the prompt to pass to OpenAI
            prompt = (
                "Based on the following git diff, provide a concise GitHub commit subject "
                "following GitHub's commit message convention:\n\n"
                f"{diff}"
            )

            # Call OpenAI API to get the commit subject
            response = client.responses.create(
                model="gpt-4",
                instructions="You are an expert at crafting concise GitHub commit messages. Respond with a single, well-written commit message only.",
                input=prompt
            )

            return response.output_text
        except Exception as e:
            logger.error(f"Error generating commit subject using OpenAI: {str(e)}")
            raise e
            # return "Update repository contents"  # Fallback subject

    def scan_and_process_modules(self) -> List[dict]:
        """Scan through provider folders and process modules"""
        results = []

        for provider in self.provider_folders:
            provider_path = os.path.join(self.base_dir, provider)

            logger.info(f"List modules in provider folder: {os.listdir(provider_path)}")

            for module_name in os.listdir(provider_path):
                module_path = os.path.join(provider_path, module_name)

                if os.path.isdir(module_path):
                    result = self.process_module(provider, module_name, module_path)
                    results.append(result)

        return results

    def copy_module_files(self, source_path, destination_path):
        """Copy module files to the destination repository"""
        try:
            for item in os.listdir(source_path):
                source_item = os.path.join(source_path, item)
                dest_item = os.path.join(destination_path, item)

                if os.path.isfile(source_item):
                    if os.path.isfile(dest_item):
                        os.remove(dest_item)
                    shutil.copy2(source_item, dest_item)
                elif os.path.isdir(source_item):
                    if os.path.isdir(dest_item):
                        shutil.rmtree(dest_item)
                    shutil.copytree(source_item, dest_item)

            logger.info(f"Module files copied successfully to {destination_path}")
        except Exception as e:
            logger.error(f"Error copying module files: {str(e)}", exc_info=True)
            raise


def parse_arguments():
    parser = argparse.ArgumentParser(
        description='Terraform Module Publisher - Create GitHub repositories for Terraform modules')
    parser.add_argument(
        '--base-dir',
        type=str,
        default=os.getcwd(),
        help='Base directory containing the provider folders (default: current working directory)'
    )

    # Adding the new `module-path` argument
    parser.add_argument(
        "--module-path",
        required=False,
        default=None,
        help=(
            "Specify the path to a specific module to process. "
            "If omitted, all modules in the base directory will be scanned and processed."
        ),
    )
    return parser.parse_args()


def validate_base_dir(base_dir: str) -> None:
    """Validate the base directory structure"""
    base_path = Path(base_dir)

    if not base_path.is_dir():
        raise ValueError(f"Base directory does not exist: {base_dir}")

    # Check for at least one provider directory
    provider_exists = False
    for provider in ['aws', 'datadog', 'gcp', 'github']:
        if (base_path / provider).is_dir():
            provider_exists = True
            break

    if not provider_exists:
        raise ValueError(
            f"No provider directories found in {base_dir}. Expected at least one of: aws, datadog, gcp, github")


def _get_meta_repo(meta_repo_url: str) -> Repo:
    meta_repo_path = os.getenv('META_REPO_PATH')

    if meta_repo_path is not None and os.path.exists(meta_repo_path):
        return Repo(path=meta_repo_path)
    else:
        if meta_repo_path is None:
            meta_repo_path = tempfile.mkdtemp()
        logger.info(f"Meta-repo not found at '{meta_repo_path}'. Cloning into the directory...")
        try:
            gh_app_private_key = _get_github_app_private_key()

            meta_repo = clone_with_github_app(
                meta_repo_url=meta_repo_url,
                meta_repo_path=meta_repo_path,
                private_key=gh_app_private_key,
                app_id=GH_APP_ID,
                installation_id=GH_APP_INSTALLATION_ID
            )
            return meta_repo
        except Exception as e:
            raise Exception(f"Failed to clone meta-repo: {e}") from e

def _get_github_app_private_key() -> str:
    if GH_APP_PRIVATE_KEY is not None:
        return GH_APP_PRIVATE_KEY

    secret_file_path = os.path.join(os.getcwd(), "credentials", "github_app_private_key.pem")
    try:
        with open(secret_file_path, "r") as file:
            return file.read()
    except FileNotFoundError:
        raise Exception(f"Secret file not found at {secret_file_path}")


def create_jwt(app_id: str, private_key: str) -> str:
    """
    Generates a JWT for authenticating GitHub App requests.
    """
    now = int(datetime.datetime.now().timestamp())
    payload = {
        "iat": now - 60,  # Issued 60 seconds in the past to handle clock skew
        "exp": now + (10 * 60),  # Token valid for 10 minutes
        "iss": app_id,  # App ID
    }
    return jwt.encode(payload, private_key, algorithm='RS256')


def get_installation_access_token(app_id: str, private_key: str, installation_id: str) -> str:
    """
    Exchanges a GitHub App JWT for an installation access token.
    """
    jwt_token = create_jwt(app_id, private_key)
    headers = {"Authorization": f"Bearer {jwt_token}", "Accept": "application/vnd.github+json"}
    url = f"https://api.github.com/app/installations/{installation_id}/access_tokens"

    response = requests.post(url, headers=headers)
    if response.status_code == 201:
        return response.json().get("token")
    else:
        raise Exception(f"Failed to obtain installation token: {response.json()}")


def clone_with_github_app(meta_repo_url: str, meta_repo_path: str, app_id: str, private_key: str, installation_id: str) -> Repo:
    installation_token = get_installation_access_token(app_id=app_id, private_key=private_key, installation_id=installation_id)

    auth_repo_url = meta_repo_url.replace(
        "https://github.com", f"https://x-access-token:{installation_token}@github.com"
    )

    try:
        return Repo.clone_from(url=auth_repo_url, to_path=meta_repo_path)
    except Exception as e:
        raise Exception(f"Failed to clone meta-repo with GitHub App: {e}") from e


def main():
    args = parse_arguments()
    base_dir = os.path.abspath(args.base_dir)
    module_path = args.module_path

    try:
        validate_base_dir(base_dir)

        logger.info(f"Using base directory: {base_dir}")
        publisher = TerraformModulePublisher(
            github_token=PAT_TOKEN, org_name=GITHUB_ORG, base_dir=base_dir
        )

        if module_path:
            logger.info(f"Processing only the specified module at: {module_path}")
            provider = module_path.split("/")[0]
            module_name = module_path.split("/")[1]
            results = [publisher.process_module(
                provider=provider,
                module_name=module_name,
                module_path=os.path.join(base_dir, module_path)
            )]
        else:
            results = publisher.scan_and_process_modules()

        # Print results
        print("\nProcessing Results:")
        print("==================")

        # Group results by status
        status_groups = {
            'success': [],
            'skipped': [],
            'error': []
        }

        for result in results:
            status_groups[result['status']].append(result)

        # Print successful results
        if status_groups['success']:
            print("\n✅ Successfully processed:")
            for result in status_groups['success']:
                print(f"  - {result['repo_name']}")
                print(f"    URL: {result['repo_url']}")

        # Print skipped results
        if status_groups['skipped']:
            print("\n⏭️  Skipped:")
            for result in status_groups['skipped']:
                print(f"  - {result['repo_name']}: {result['message']}")

        # Print errors
        if status_groups['error']:
            print("\n❌ Errors:")
            for result in status_groups['error']:
                print(f"  - {result['repo_name']}: {result['message']}")

        # Print summary
        print("\nSummary:")
        print(f"Base directory: {base_dir}")
        print(f"Total modules processed: {len(results)}")
        print(f"Successful: {len(status_groups['success'])}")
        print(f"Skipped: {len(status_groups['skipped'])}")
        print(f"Errors: {len(status_groups['error'])}")

    except Exception as e:
        logger.error(f"Error in main execution: {str(e)}", exc_info=True)
        raise


if __name__ == "__main__":
    main()
