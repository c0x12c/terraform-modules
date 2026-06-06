/**
Generates an IAM policy document in JSON format.
This block generates required assume role actions to provider.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
 */
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.provider.arn]
    }
  }
}

/**
This block provides an IAM role to Jenkins OIDC.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
 */
resource "aws_iam_role" "oidc" {
  name               = var.role_name_prefix == "" ? "${var.role_name}" : "${var.role_name_prefix}-${var.role_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

/**
Generates an IAM policy document in JSON format.
This block generates required actions for Jenkins.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
 */
data "aws_iam_policy_document" "oidc" {
  dynamic "statement" {
    for_each = length(var.custom_oidc_policy_statement) > 0 ? var.custom_oidc_policy_statement : toset(local.default_oidc_policy_statement)

    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

/**
This block create an IAM policy for Jenkins OIDC to access AWS resources.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
 */
resource "aws_iam_policy" "oidc" {
  name        = var.oidc_policy_name != null ? var.oidc_policy_name : "jenkins_oidc_policy"
  description = var.oidc_policy_description
  policy      = data.aws_iam_policy_document.oidc.json
}

/**
This block create a policy attachment to Jenkins OIDC role.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
 */
resource "aws_iam_role_policy_attachment" "oidc" {
  depends_on = [aws_iam_policy.oidc]

  role       = aws_iam_role.oidc.name
  policy_arn = aws_iam_policy.oidc.arn
}
