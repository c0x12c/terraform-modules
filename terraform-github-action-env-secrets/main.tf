/**
https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment
*/
resource "github_repository_environment" "this" {
  count = var.create_environment ? 1 : 0

  repository  = var.repository
  environment = var.environment
}

/**
https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret
*/
resource "github_actions_environment_secret" "this" {
  for_each = var.secrets

  repository      = var.repository
  environment     = var.create_environment ? github_repository_environment.this[0].environment : var.environment
  secret_name     = each.key
  plaintext_value = each.value
}
