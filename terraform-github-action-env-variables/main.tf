/**
`github_repository_environment` creates a GitHub environment if it doesn't already exist.
Environments allow you to configure protection rules and secrets for deployments.

https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment
*/

resource "github_repository_environment" "this" {
  count = var.create_environment ? 1 : 0

  repository  = var.repository
  environment = var.environment
}

/**
`github_actions_environment_variable` allows you to create and manage GitHub Actions variables
within your GitHub repository environments. Environment variables are non-sensitive configuration
values scoped to specific deployment environments.

Must have write access to a repository to use this resource.

https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable
*/

resource "github_actions_environment_variable" "this" {
  for_each = var.variables

  repository    = var.repository
  environment   = var.create_environment ? github_repository_environment.this[0].environment : var.environment
  variable_name = each.key
  value         = each.value
}
