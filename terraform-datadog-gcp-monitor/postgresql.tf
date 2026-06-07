module "postgres_monitor" {
  source = "../terraform-datadog-monitors"

  notification_slack_channel_prefix = var.notification_slack_channel_prefix
  tag_slack_channel                 = var.tag_slack_channel
  environment                       = var.environment
  service                           = "postgres"

  monitors = {
    for monitor, config in local.default_postgres_monitor :
    monitor => merge(config, try(var.override_default_monitors[monitor], {})) if var.postgres_monitor_enabled
  }
}