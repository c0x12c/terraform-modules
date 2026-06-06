data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.aws_load_balancer_controller_name}"]
    }

    principals {
      identifiers = [var.oidc_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
  name               = "${var.cluster_name}-aws-load-balancer-controller-role"
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  policy = file(local.policy_file)
  name   = "${var.cluster_name}-load-balancer-controller-policy"
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}
