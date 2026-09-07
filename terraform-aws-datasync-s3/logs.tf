# BASIC is the finest CloudWatch level DataSync offers (transfer errors only);
# per-object detail comes from the task report instead.
resource "aws_cloudwatch_log_group" "this" {
  count = local.logging ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id
  tags              = var.tags
}

data "aws_iam_policy_document" "logs" {
  count = local.logging && var.create_cloudwatch_log_resource_policy ? 1 : 0

  statement {
    sid    = "DataSyncLogsToCloudWatchLogs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.this[0].arn}:*"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      # Region read off the log group ARN so the module needs no aws_region data source.
      values = ["arn:${data.aws_partition.current.partition}:datasync:${split(":", aws_cloudwatch_log_group.this[0].arn)[3]}:${data.aws_caller_identity.current.account_id}:task/*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

# CloudWatch Logs allows only 10 resource policies per region, and this one
# already covers every DataSync task in the account: set
# create_cloudwatch_log_resource_policy = false on additional instances.
resource "aws_cloudwatch_log_resource_policy" "this" {
  count = local.logging && var.create_cloudwatch_log_resource_policy ? 1 : 0

  policy_name     = "${var.name}-datasync-logs"
  policy_document = data.aws_iam_policy_document.logs[0].json
}
