data "aws_iam_policy_document" "this_cluster_role" {
  count = local.cluster_roles_count
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    principals {
      type        = "AWS"
      identifiers = var.cluster_roles[count.index].trusted_role_arn
    }
  }
}

data "aws_iam_policy_document" "this_namespace_role" {
  count = local.namespace_role_count
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    principals {
      type        = "AWS"
      identifiers = var.namespace_roles[count.index].trusted_role_arn
    }
  }
}
