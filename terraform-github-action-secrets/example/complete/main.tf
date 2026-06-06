module "github_actions_secrets" {
  source = "../../"

  repository = "service-platform"
  secrets = {
    "SECRET" = "value"
  }
}
