data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.lambda_source_file
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "notifier" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.name}-notifier"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = var.lambda_handler
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = var.lambda_runtime

  environment {
    variables = merge(
      {
        SLACK_WEBHOOK_URL = var.slack_webhook_url
        ENVIRONMENT       = var.environment
      },
      var.lambda_environment_variables
    )
  }

  depends_on = [aws_iam_role.lambda_exec_role]
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for rule in var.event_rules : rule.name => rule }

  name          = each.value.name
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for rule in var.event_rules : rule.name => rule }

  rule      = aws_cloudwatch_event_rule.this[each.key].name
  target_id = "SendToLambda-${each.key}"
  arn       = aws_lambda_function.notifier.arn

  depends_on = [aws_lambda_function.notifier]
}

resource "aws_lambda_permission" "allow_eventbridge" {
  for_each = { for rule in var.event_rules : rule.name => rule }

  statement_id  = "AllowExecutionFromEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifier.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[each.key].arn

  depends_on = [aws_lambda_function.notifier]
}
