data "aws_iam_policy_document" "fluent_bit_eks_fargate_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
    ]
    resources = ["*"]
  }
}

resource "kubernetes_namespace" "aws_observability" {
  metadata {
    name = "aws-observability"
    labels = {
      "aws-observability" = "enabled"
    }
  }
}

resource "kubernetes_config_map" "aws_logging" {
  metadata {
    name      = "aws-logging"
    namespace = "aws-observability"
  }

  data = {
    "output.conf" = local.fluent_bit_config_outut
  }

  depends_on = [kubernetes_namespace.aws_observability]
}

resource "aws_iam_policy" "fluent_bit_eks_fargate" {
  name = "${var.name}-fluent-bit-eks-fargate"

  policy = data.aws_iam_policy_document.fluent_bit_eks_fargate_policy.json
}

resource "aws_iam_role_policy_attachment" "fargate_fluent_bit" {
  policy_arn = aws_iam_policy.fluent_bit_eks_fargate.arn
  role       = var.fargate_profile_pod_execution_role_name
}
