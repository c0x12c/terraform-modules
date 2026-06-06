locals {
  sa_mapping = {
    for repo in var.github_repos : repo => {
      sa_name   = "projects/${var.gcp_project_id}/serviceAccounts/${var.gcp_service_account_id}@${var.gcp_project_id}.iam.gserviceaccount.com"
      attribute = "attribute.repository/${repo}"
    }
  }
}

/**
This module handles the opinionated creation of infrastructure necessary to configure Workload Identity pools and providers for authenticating to GCP using GitHub Actions OIDC tokens.
This includes:
- Creation of a Workload Identity pool.
- Configuring a Workload Identity provider.
- Granting external identities necessary IAM roles on Service Accounts.
 */
module "gh_oidc" {
  source  = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  version = "5.1.0"

  project_id          = var.gcp_project_id
  pool_id             = var.gcp_pool_id
  provider_id         = var.gcp_provider_id
  attribute_condition = "assertion.repository_owner == '${var.github_org}'"

  sa_mapping = local.sa_mapping

  attribute_mapping = {
    "attribute.actor" : "assertion.actor",
    "attribute.aud" : "assertion.aud",
    "attribute.repository" : "assertion.repository",
    "attribute.repository_owner" = "assertion.repository_owner"
    "google.subject" : "assertion.sub",
  }
}
