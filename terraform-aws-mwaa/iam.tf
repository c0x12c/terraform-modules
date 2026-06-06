# ---------------------------------------------------------------------------------------------------------------------
# IAM Role
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = var.create_iam_role ? 1 : 0

  name               = var.iam_role_name != null ? var.iam_role_name : null
  description        = "MWAA IAM Role"
  assume_role_policy = data.aws_iam_policy_document.mwaa_assume.json
}

resource "aws_iam_role_policy" "this" {
  count = var.create_iam_role ? 1 : 0

  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.mwaa.json
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = local.iam_role_additional_policies
  policy_arn = each.value
  role       = aws_iam_role.this[0].id
}
