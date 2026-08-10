output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule."
  value       = aws_cloudwatch_event_rule.this.arn
}

output "eventbridge_rule_name" {
  description = "Name of the EventBridge rule."
  value       = aws_cloudwatch_event_rule.this.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic events are published to."
  value       = local.sns_topic_arn
}

output "sns_topic_name" {
  description = "Name of the created SNS topic, or null when an existing topic is reused."
  value       = try(aws_sns_topic.this[0].name, null)
}

output "subscription_arns" {
  description = "ARNs of the plain SNS subscriptions, keyed as in var.subscriptions."
  value       = { for k, v in aws_sns_topic_subscription.this : k => v.arn }
}

output "iam_role_arn" {
  description = "ARN of the shared IAM role assumed by AWS Chatbot."
  value       = local.chatbot_role
}

output "iam_role_name" {
  description = "Name of the created IAM role, or null when none was created."
  value       = try(aws_iam_role.chatbot[0].name, null)
}

output "slack_channel_arns" {
  description = "ARNs of the Chatbot Slack channel configurations, keyed as in var.slack_channels."
  value       = { for k, v in aws_chatbot_slack_channel_configuration.this : k => v.chat_configuration_arn }
}

output "teams_channel_arns" {
  description = "ARNs of the Chatbot Teams channel configurations, keyed as in var.teams_channels."
  value       = { for k, v in aws_chatbot_teams_channel_configuration.this : k => v.chat_configuration_arn }
}
