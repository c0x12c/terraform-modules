resource "aws_sns_topic" "ses_notification_topic" {
  name = local.name
}

resource "aws_ses_identity_notification_topic" "bounce" {
  for_each = var.ses_identity_ids

  topic_arn                = aws_sns_topic.ses_notification_topic.arn
  notification_type        = "Bounce"
  identity                 = each.value
  include_original_headers = true
}

resource "aws_ses_identity_notification_topic" "complaint" {
  for_each = var.ses_identity_ids

  topic_arn                = aws_sns_topic.ses_notification_topic.arn
  notification_type        = "Complaint"
  identity                 = each.value
  include_original_headers = true
}

resource "aws_ses_identity_notification_topic" "delivery" {
  for_each = var.ses_identity_ids

  topic_arn                = aws_sns_topic.ses_notification_topic.arn
  notification_type        = "Delivery"
  identity                 = each.value
  include_original_headers = true
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "cloudwatch" {
  count = var.enabled_outgoing_email_logs_cloudwatch == true ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch" {
  count  = var.enabled_outgoing_email_logs_cloudwatch == true ? 1 : 0
  name   = "cloudwatch"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.cloudwatch[0].json
}

data "archive_file" "this" {
  type             = "zip"
  source_dir       = "${path.module}/lambda"
  output_file_mode = "0666"
  output_path      = "${path.module}/lambda.zip"
}


resource "aws_lambda_function" "this" {
  filename      = data.archive_file.this.output_path
  function_name = local.name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.handler"

  source_code_hash = data.archive_file.this.output_base64sha256

  runtime     = "nodejs22.x"
  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      DD_ENV     = var.environment
      DD_API_KEY = var.datadog_api_key
      DD_SITE    = var.datadog_site
      DD_SOURCE  = local.dd_source
      DD_SERVICE = local.dd_service
    }
  }
}

resource "aws_sns_topic_subscription" "sns_lambda_subscription" {
  topic_arn = aws_sns_topic.ses_notification_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.this.arn

  raw_message_delivery = false
}

resource "aws_lambda_permission" "sns_invoke_permission" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
  function_name = aws_lambda_function.this.function_name
  source_arn    = aws_sns_topic.ses_notification_topic.arn
}
