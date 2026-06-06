data "aws_iam_policy_document" "this" {
  statement {
    sid    = "sts"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = var.assume_role_arns
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "assume-role-policy"
  role   = var.keda_operator_role_id
  policy = data.aws_iam_policy_document.this.json
}
