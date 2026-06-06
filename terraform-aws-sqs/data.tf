/*
aws_caller_identity provides information about the AWS account that is making the Terraform API calls.
Used here to dynamically configure SQS permissions for the current AWS account.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
*/
data "aws_caller_identity" "current" {}

/**
`aws_region` provides information about AWS region that is making the Terraform API calls.
Used here to dynamically configure SQS permissions for the current AWS account.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region
 */
data "aws_region" "current" {}
