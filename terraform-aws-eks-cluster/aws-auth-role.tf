data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
      "sts:SetSourceIdentity"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  dynamic "statement" {
    for_each = var.administrator_role_arn != null ? [1] : []
    content {
      actions = [
        "sts:AssumeRole"
      ]
      principals {
        type        = "AWS"
        identifiers = [var.administrator_role_arn]
      }
    }
  }
}

data "aws_iam_policy_document" "auth_policy" {
  statement {
    effect    = "Allow"
    actions   = ["eks:ListClusters"]
    resources = ["*"]
    sid       = "ListAllEKSclusters"
  }

  statement {
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = [aws_eks_cluster.master.arn]
    sid       = "ReadAllEKSclusters"
  }
}

data "aws_iam_policy_document" "users_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.auth_role.arn]
    sid       = "AllowAssumeOrganizationAccountRole"
  }
}

resource "aws_iam_role" "auth_role" {
  name               = "${local.cluster_name}-auth-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

resource "aws_iam_role_policy" "eks_policy" {
  name = "${local.cluster_name}-auth-policy"
  role = aws_iam_role.auth_role.id

  policy = data.aws_iam_policy_document.auth_policy.json
}


resource "aws_iam_group" "eks_users" {
  name = "${local.cluster_name}-users"
  path = "/users/"
}

resource "aws_iam_group_policy" "eks_users" {
  name  = "${local.cluster_name}-users-policy"
  group = aws_iam_group.eks_users.name

  policy = data.aws_iam_policy_document.users_policy.json
}
