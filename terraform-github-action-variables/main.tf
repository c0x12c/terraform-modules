/**
`github_actions_variable` allows you to create and manage GitHub Actions variables within your GitHub repositories.
Must have write access to a repository to use this resource.
https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable
 */
resource "github_actions_variable" "this" {
  for_each = var.variables

  repository    = var.repository
  variable_name = each.key
  value         = each.value
}
