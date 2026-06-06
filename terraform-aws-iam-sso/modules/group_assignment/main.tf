/**
`aws_ssoadmin_instances` is used to get ARNs and Identity Store IDs of Single Sign-On (SSO) Instances.
This data source has no required arguments, as it fetches all SSO instances in the account automatically.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances
 */
data "aws_ssoadmin_instances" "sso" {}

/**
`aws_ssoadmin_account_assignment` is used to manage account assignments within AWS Single Sign-On (SSO).
This allows you to assign users or groups to AWS accounts with specific permission sets, enabling fine-grained access control.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment
 */
resource "aws_ssoadmin_account_assignment" "group_assignment" {
  for_each = var.permission_set_arns

  instance_arn       = local.identity_store_arn
  principal_type     = "GROUP"
  principal_id       = var.group_id
  permission_set_arn = each.value
  target_id          = var.aws_account_id
  target_type        = "AWS_ACCOUNT"
}
