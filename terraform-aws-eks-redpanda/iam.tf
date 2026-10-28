################################################################################
# Broker node role
################################################################################

data "aws_iam_policy_document" "node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  count = var.node_group.create ? 1 : 0

  name_prefix        = "${substr(local.aws_name, 0, 30)}-node-"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = var.node_group.create ? toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKS_CNI_Policy",
    "AmazonEC2ContainerRegistryReadOnly",
    "AmazonSSMManagedInstanceCore",
  ]) : toset([])

  role       = aws_iam_role.node[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/${each.value}"
}

data "aws_partition" "current" {}

################################################################################
# Tiered storage: IRSA role for the broker service account
################################################################################

data "aws_iam_policy_document" "tiered_assume" {
  count = var.tiered_storage.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider.url}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${local.service_account}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider.url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "tiered" {
  count = var.tiered_storage.enabled ? 1 : 0

  name_prefix        = "${substr(local.aws_name, 0, 30)}-s3-"
  assume_role_policy = data.aws_iam_policy_document.tiered_assume[0].json
  tags               = var.tags
}

data "aws_iam_policy_document" "tiered" {
  count = var.tiered_storage.enabled ? 1 : 0

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${local.tiered_bucket}"]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
    ]
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${local.tiered_bucket}/*"]
  }
}

resource "aws_iam_role_policy" "tiered" {
  count = var.tiered_storage.enabled ? 1 : 0

  name   = "tiered-storage"
  role   = aws_iam_role.tiered[0].id
  policy = data.aws_iam_policy_document.tiered[0].json
}
