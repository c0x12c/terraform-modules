/**
Use this data source to get the access to the effective Account ID, User ID, and ARN in which Terraform is authorized.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
 */
data "aws_caller_identity" "this" {}

/**
Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
 */
data "aws_iam_policy_document" "assume_role_github" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
      type        = "AWS"
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      identifiers = [module.provider.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "${module.provider.url}:aud"
    }

    dynamic "condition" {
      for_each = var.conditions

      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

/**
Provides an IAM role.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
 */
resource "aws_iam_role" "github_actions_role" {
  name               = var.role_name_prefix == "" ? "${var.role_name}" : "${var.role_name_prefix}-${var.role_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_github.json
}

/**
Attaches a Managed IAM Policy to an IAM role.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
 */
resource "aws_iam_role_policy_attachment" "github_actions_role_policy" {
  for_each   = toset(var.role_policy_arns)
  role       = aws_iam_role.github_actions_role.id
  policy_arn = each.value
}
