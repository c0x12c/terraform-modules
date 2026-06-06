module "group" {
  source  = "c0x12c/google-workspace-group/gcp"
  version = "~> 1.0.0"

  for_each = var.groups

  description = each.value.description
  domain      = var.domain
  identifier  = each.key
  members     = each.value.members
  name        = each.value.name
}
