data "aws_iam_policy_document" "vanta_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "codecommit:GetApprovalRuleTemplate",
      "codecommit:ListPullRequests",
      "codecommit:GetCommentsForPullRequest",
      "codecommit:GetPullRequest",
      "codecommit:GetPullRequestApprovalStates",
      "identitystore:DescribeGroup",
      "identitystore:DescribeGroupMembership",
      "identitystore:DescribeUser",
      "identitystore:GetGroupId",
      "identitystore:GetGroupMembershipId",
      "identitystore:GetUserId",
      "identitystore:IsMemberInGroups",
      "identitystore:ListGroupMemberships",
      "identitystore:ListGroups",
      "identitystore:ListUsers",
      "identitystore:ListGroupMembershipsForMember",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Deny"
    actions = [
      "datapipeline:EvaluateExpression",
      "datapipeline:QueryObjects",
      "rds:DownloadDBLogFilePortion"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::${var.vanta_aws_account_id}:role/scanner"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      values   = [var.vanta_scanner_external_id]
      variable = "sts:ExternalId"
    }
  }
}
