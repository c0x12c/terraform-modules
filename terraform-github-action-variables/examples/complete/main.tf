module "github_actions_variables" {
  source = "../../"

  repository = "service-platform"
  variables = {
    "VARIABLE" = "value"
  }
}
