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
  environment   = var.environment
  variable_name = each.key
  value         = each.value
}
