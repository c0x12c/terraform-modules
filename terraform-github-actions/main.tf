module "action-secret" {
  source = "../terraform-github-action-secrets"

  for_each   = var.repository_secrets
  repository = each.key
  secrets    = each.value
}

module "action-variables" {
  source = "../terraform-github-action-variables"

  for_each   = var.repository_variables
  repository = each.key
  variables  = each.value
}
