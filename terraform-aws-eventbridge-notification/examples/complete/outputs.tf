output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule."
  value       = module.eventbridge_notification.eventbridge_rule_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic."
  value       = module.eventbridge_notification.sns_topic_arn
}

output "slack_channel_arns" {
  description = "ARNs of the Chatbot Slack channel configurations."
  value       = module.eventbridge_notification.slack_channel_arns
}
