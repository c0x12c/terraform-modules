module "groups" {
  source = "./modules/group"

  for_each = var.groups

  group_name   = each.key
  aws_accounts = each.value.aws_accounts
  users        = each.value.users != null ? each.value.users : {}
}
