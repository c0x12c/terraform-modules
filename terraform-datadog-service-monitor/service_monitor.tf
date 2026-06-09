module "service" {
  source = "../terraform-datadog-monitors"

  notification_slack_channel_prefix = var.notification_slack_channel_prefix
  tag_slack_channel                 = var.tag_slack_channel
  environment                       = var.environment
  service                           = var.service_name

  monitors = {
    for monitor, config in local.default_service_monitors :
    monitor => merge(config, try(local.override_default_monitors_clean[monitor], {})) if var.service_monitor_enabled
  }
}
