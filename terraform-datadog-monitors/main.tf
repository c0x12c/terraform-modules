locals {
  notifiers = "@slack-${var.notification_slack_channel_prefix}${var.environment}"
  message   = format("%s%s", local.notifiers, var.tag_slack_channel ? " <!channel>" : "")
}

resource "datadog_monitor" "this" {
  for_each = { for name, monitor in var.monitors : name => monitor if monitor.enabled }

  name     = "[P${each.value.priority_level}] ${each.value.title_tags}: ${upper(var.environment)} - ${each.value.title}"
  type     = each.value.type
  message  = coalesce(each.value.override_default_message, each.value.priority_level >= 4 ? "" : local.message)
  priority = each.value.priority_level
  query = templatestring(each.value.query_template, merge(each.value.query_args, {
    threshold_critical = each.value.threshold_critical
  }))
  monitor_thresholds {
    critical          = each.value.threshold_critical
    critical_recovery = each.value.threshold_critical_recovery
    ok                = each.value.threshold_ok
    warning           = each.value.threshold_warning
    warning_recovery  = each.value.threshold_warning_recovery
  }

  renotify_interval = each.value.renotify_interval
  renotify_statuses = ["alert"]

  timeout_h                = 1
  renotify_occurrences     = try(each.value.renotify_occurrences)
  require_full_window      = each.value.require_full_window
  include_tags             = each.value.enabled_include_tags
  tags                     = concat(["env:${var.environment}", "service:${var.service}"], each.value.additional_tags)
  notification_preset_name = each.value.notification_preset_name
}
