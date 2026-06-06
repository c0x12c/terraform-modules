module "action-secret" {
  source  = "c0x12c/action-secrets/github"
  version = "~> 1.0.1"

  for_each   = var.repository_secrets
  repository = each.key
  secrets    = each.value
}

module "action-variables" {
  source  = "c0x12c/action-variables/github"
  version = "~> 1.0.0"

  for_each   = var.repository_variables
  repository = each.key
  variables  = each.value
}
