locals {
  identity_store_arn = data.aws_ssoadmin_instances.sso.arns[0]
}
