output "notification_rule_ids" {
  value = [for rule in values(datadog_monitor_notification_rule.this) : rule.id]
}
