import os
import subprocess
from github import Github
from typing import List

GH_APP_ID = os.getenv("GH_APP_ID")
GH_APP_INSTALLATION_ID = os.getenv("GH_APP_INSTALLATION_ID")
GH_APP_PRIVATE_KEY = os.getenv("GH_APP_PRIVATE_KEY")
GITHUB_ORG = os.getenv("GITHUB_ORG")
PAT_TOKEN = os.getenv("PAT_TOKEN")


# Utility functions
def execute_command(command: List[str], cwd: str = None):
    """Executes a system command."""
    try:
        result = subprocess.run(command, cwd=cwd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(result.stdout.decode())
    except subprocess.CalledProcessError as e:
        print(e.stderr.decode())
        raise e


def clone_meta_repo(repo_url: str, clone_dir: str):
    """Clone the meta repository."""
    if os.path.exists(clone_dir):
        print(f"Directory {clone_dir} already exists. Skipping clone!")
        return
    execute_command(["git", "clone", repo_url, clone_dir])


def fetch_submodules(clone_dir: str):
    """Fetch all submodules in the repository."""
    execute_command(["git", "submodule", "update", "--init", "--recursive"], cwd=clone_dir)


def check_and_set_branch_protection(repo, branch: str):
    """Checks and sets branch protection rules for a branch."""
    print(f"Checking branch protection for {repo.full_name} on branch {branch}")
    try:
        # Check if branch protection exists
        existing_protection = repo.get_branch(branch).protection
        print(f"Branch protection already exists for {branch}. Updating rules...")
        existing_protection.edit(
            required_approving_review_count=2,
            enforce_admins=True
        )
    except Exception:
        # Branch protection does not exist, create it
        print(f"No branch protection exists for {branch}. Creating...")
        branch = repo.get_branch(branch)
        branch.edit_protection(
            required_approving_review_count=2,
            enforce_admins=True
        )


def check_and_set_tag_protection(repo):
    """Checks and sets tag protection rules for a repository."""
    print(f"Checking tag protection for {repo.full_name}")
    try:
        # Check if any tag protection rules already exist
        tag_protections = repo.get_tag_protections()
        if tag_protections:
            print(f"Tag protection already exists in repository. Updating or skipping...")
        else:
            print("No existing tag protection found, creating one...")
            repo.create_tag_protection(name_pattern="*", include_lights=True)
    except Exception as e:
        print(f"Failed to check or set tag protection for {repo.full_name}: {e}")


def main():
    # Meta repository details
    meta_repo_url = f"https://github.com/{GITHUB_ORG}/meta-repo"
    clone_dir = "/tmp/meta_repo"

    # Clone meta repository
    clone_meta_repo(meta_repo_url, clone_dir)

    # Fetch submodules
    fetch_submodules(clone_dir)

    # Initialize GitHub client with token or app credentials
    token_or_app_credentials = "<YOUR_ACCESS_TOKEN>"  # Replace as appropriate
    github = Github(token_or_app_credentials)
    org = github.get_organization(GITHUB_ORG)

    # Loop through all submodules and set protections
    submodules_file = os.path.join(clone_dir, ".gitmodules")
    with open(submodules_file, "r") as file:
        submodule_urls = [line.split("url = ")[1].strip() for line in file if "url =" in line]

    for url in submodule_urls:
        repo_name = url.split("/")[-1].replace(".git", "")
        try:
            repo = org.get_repo(repo_name)
            check_and_set_branch_protection(repo, branch="main")
            check_and_set_tag_protection(repo)
        except Exception as e:
            print(f"Failed to process repository {repo_name}: {e}")


if __name__ == "__main__":
    main()
