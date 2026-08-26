# Connect the repository with a short-lived GitHub App installation token rather than a PAT, so
# there is no long-lived credential to store or rotate. See README.md for why it must be
# github_oauth_token and not github_token.

data "github_app_token" "this" {
  app_id          = var.github_app_id
  installation_id = var.github_app_installation_id
  pem_file        = var.github_app_pem_file
}

module "website" {
  source = "../../"

  dns_zone         = "example.com"
  environment      = "dev"
  repository       = "https://github.com/example-org/example-repo"
  application_root = "./"

  github_oauth_token = data.github_app_token.this.token

  # aws provider 5.100.0 cannot read aws_amplify_webhook back, leaving it permanently tainted.
  # Opt out there and start the first build with `aws amplify start-job`.
  enable_build_webhook = false

  deploy_branch_name       = "master"
  sub_domain               = "test"
  name                     = "example"
  install_command          = "yarn install"
  build_command            = "yarn build"
  base_artifacts_directory = ".next"
  web_platform             = "WEB_COMPUTE"
  enable_backend           = false
}
