/*
data "aws_region" "current" retrieves information about the current AWS region.
This data source helps in dynamically referencing the region for resources and configuration.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region
*/
data "aws_region" "current" {}

/*
data "aws_caller_identity" "current" retrieves the identity and account information for the caller (the AWS account making the request).
This is useful for constructing resource ARNs and applying security policies based on the caller's account ID.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
*/
data "aws_caller_identity" "current" {}

/*
data "aws_iam_policy_document" "this" creates an IAM policy document that defines access control for the OpenSearch domain.
The policy grants permissions to principals to access the specified OpenSearch domain.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
*/
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.principal_roles != null ? var.principal_roles : ["*"]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*"]
  }
}
