resource "aws_cloudwatch_log_group" "this" {
  count = var.create_cloudwatch_log_group ? 1 : 0
  name  = "/cloudtrail/${var.name}-logs"
}

resource "aws_iam_role" "cloudwatch" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name = "CloudTrailRoleForCloudWatchLogs_${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
    }]
  })
}

data "aws_iam_policy_document" "cloudwatch" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  statement {
    sid    = "AllowCreateLogGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.this[0].name}"
    ]
  }

  statement {
    sid    = "AWSCloudTrailPutLogStream"
    effect = "Allow"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.this[0].name}:log-stream:*"
    ]
  }
}

resource "aws_iam_policy" "cloudwatch" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name   = "CloudTrail-${var.name}-logs-policy"
  policy = data.aws_iam_policy_document.cloudwatch[0].json
}

resource "aws_iam_role_policy_attachment" "example" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  role       = aws_iam_role.cloudwatch[0].name
  policy_arn = aws_iam_policy.cloudwatch[0].arn
}
