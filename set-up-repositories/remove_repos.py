import os

from dotenv import load_dotenv
from github import Github

load_dotenv()

PAT_TOKEN = os.getenv('PAT_TOKEN')

if not PAT_TOKEN:
    raise EnvironmentError("The 'PAT_TOKEN' environment variable is not set.")


def delete_repos_in_org(token, org_name, file_path=None, confirmation=False):
    """
    Deletes repositories in a GitHub organization.

    Args:
        token (str): GitHub personal access token with appropriate permissions.
        org_name (str): Name of the organization.
        file_path (str, optional): Path to the file containing repository names, one per line.
        confirmation (bool): Whether to prompt for confirmation before deletion. Default is False.
    """
    try:
        # Authenticate with GitHub
        github_client = Github(token)
        org = github_client.get_organization(org_name)

        # Fetch all repositories in the organization
        all_repos = org.get_repos()
        all_repo_names = [repo.name for repo in all_repos]

        # Read repository names from file
        if file_path:
            with open(file_path, "r") as file:
                repo_names = [line.strip() for line in file if line.strip()]

            # Validate repository names
            invalid_repos = [repo for repo in repo_names if repo not in all_repo_names]
            if invalid_repos:
                print(
                    f"The following repositories don't exist in the organization '{org_name}': {', '.join(invalid_repos)}")
                repo_names = [repo for repo in repo_names if repo not in invalid_repos]

        if not repo_names:
            print("No matching repositories found to delete.")
            return

        print(f"Found {len(repo_names)} repositories to delete in organization '{org_name}':")
        for repo_name in repo_names:
            print(f"  - {repo_name}")

        # Confirm deletion
        if confirmation:
            confirm = input("Are you sure you want to permanently delete the above repositories? (yes/no): ")
            if confirm.strip().lower() != "yes":
                print("Aborted.")
                return

        # Delete repositories
        for repo_name in repo_names:
            repo = org.get_repo(repo_name)
            print(f"Deleting repository: {repo.name}...")
            repo.delete()
            print(f"Repository '{repo.name}' has been deleted successfully!")

        print("All specified repositories have been deleted.")
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    delete_repos_in_org(token=PAT_TOKEN, org_name='c0x12c', file_path='repos_to_delete.txt', confirmation=True)
