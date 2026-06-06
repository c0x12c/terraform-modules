data "aws_iam_policy_document" "amplify_backend" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "amplify_backend" {
  name               = "${var.name}-amplify-backend-role"
  assume_role_policy = data.aws_iam_policy_document.amplify_backend.json
}

resource "aws_iam_role_policy" "amplify_backend" {
  name = "${var.name}-amplify-iam-role-policy"
  role = aws_iam_role.amplify_backend.id

  policy = file("${path.module}/files/amplify_role_policies.json")
}
