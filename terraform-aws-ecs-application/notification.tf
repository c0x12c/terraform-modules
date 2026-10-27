module "eventbridge-slack-notification" {
  count = var.enabled_notification ? 1 : 0

  source = "../terraform-aws-eventbridge-slack-notification"

  name              = var.name
  environment       = var.environment
  slack_webhook_url = var.slack_webhook_url

  lambda_source_file = "${path.module}/files/index.mjs"
  lambda_handler     = "index.handler"
  lambda_runtime     = "nodejs22.x"

  additional_iam_policy_arns = {
    lambda_ecs_policy = aws_iam_policy.lambda_ecs_policy[0].arn
  }

  lambda_environment_variables = {
    ENVIRONMENT  = var.environment
    CLUSTER_NAME = var.ecs_cluster_name
    SERVICE_NAME = var.name
  }

  event_rules = local.notification_event_rules

  depends_on = [aws_iam_policy.lambda_ecs_policy]
}
