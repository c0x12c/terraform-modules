module "github_oidc" {
  source = "../../"

  gcp_pool_id            = "github-actions-pool"
  gcp_project_id         = "my-gcp-project"
  gcp_provider_id        = "github-provider"
  gcp_service_account_id = "github-actions-sa"
  github_org             = "my-org"
  github_repos           = ["example-repo", "my-repo"]
}
