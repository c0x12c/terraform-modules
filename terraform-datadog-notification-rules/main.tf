resource "datadog_monitor_notification_rule" "this" {
  for_each = var.notification_rules

  name       = each.value.name
  recipients = each.value.recipients
  filter {
    tags = try(each.value.filter.tags, null)
  }
}