output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule."
  value       = module.health_notification.eventbridge_rule_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic."
  value       = module.health_notification.sns_topic_arn
}

output "slack_channel_arns" {
  description = "ARNs of the Chatbot Slack channel configurations."
  value       = module.health_notification.slack_channel_arns
}

output "global_eventbridge_rule_arn" {
  description = "ARN of the us-east-1 EventBridge rule catching global events."
  value       = module.health_notification_global.eventbridge_rule_arn
}

output "global_sns_topic_arn" {
  description = "ARN of the us-east-1 SNS topic the Slack channel also subscribes to."
  value       = module.health_notification_global.sns_topic_arn
}
