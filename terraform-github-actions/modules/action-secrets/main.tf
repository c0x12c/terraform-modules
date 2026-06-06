/**
`github_actions_secret` allows you to create and manage GitHub Actions secrets within your GitHub repositories.
Must have write access to a repository to use this resource.
https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret
 */
resource "github_actions_secret" "this" {
  for_each        = var.secrets
  repository      = var.repository
  secret_name     = each.key
  plaintext_value = each.value
}
