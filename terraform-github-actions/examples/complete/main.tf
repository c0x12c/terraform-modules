module "github_actions" {
  source = "../../"

  repository_secrets = {
    "service-platform" = {
      "SECRETS_A" = "value"
      "SECRETS_B" = "value"
    }
    "web-platform" = {
      "SECRETS_A" = "value"
      "SECRETS_B" = "value"
    }
  }
  repository_variables = {}
}
