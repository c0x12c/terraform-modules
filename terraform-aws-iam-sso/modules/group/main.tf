/**
`aws_ssoadmin_instances` is used to get ARNs and Identity Store IDs of Single Sign-On (SSO) Instances.
This data source has no required arguments, as it fetches all SSO instances in the account automatically.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances
 */
data "aws_ssoadmin_instances" "sso" {}

/**
`aws_identitystore_group` is used to manage groups within AWS Identity Store.
Groups help manage permissions collectively for a set of users within an AWS organization.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group
 */
resource "aws_identitystore_group" "this" {
  display_name      = var.group_name
  description       = "${var.group_name} group"
  identity_store_id = local.identity_store_id
}

module "group_assignments" {
  source = "../group_assignment"

  for_each = var.aws_accounts

  aws_account_id      = each.key
  group_id            = aws_identitystore_group.this.group_id
  permission_set_arns = each.value
}

module "users" {
  source = "../user"

  for_each = var.users

  email             = each.key
  identity_store_id = local.identity_store_id
  first_name        = each.value.first_name
  last_name         = each.value.last_name
  user_name         = each.value.user_name
}

/**
`aws_identitystore_group_membership` is used to manage the membership of users in groups within an AWS Identity Store.
It is commonly used in conjunction with the `aws_identitystore_group` and `aws_identitystore_user` resources to define and manage user-group relationships for AWS Single Sign-On (SSO).
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership
 */
resource "aws_identitystore_group_membership" "group_membership" {
  for_each = var.users

  group_id          = aws_identitystore_group.this.group_id
  identity_store_id = local.identity_store_id
  member_id         = module.users[each.key].user_id
}
