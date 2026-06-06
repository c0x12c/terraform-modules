module "workload_identity" {
  source = "../../"

  pool_id            = "example-pool"
  project_id         = "example-project"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = "pipeline-ops@example-project.iam.gserviceaccount.com"

  provider_list = {
    github  = "https://token.actions.githubusercontent.com"
    jenkins = "https://jenkins.<domain-name>.dev/oidc"
  }
}
