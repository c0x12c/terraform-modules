module "http_check" {
  source = "../terraform-datadog-monitors"

  notification_slack_channel_prefix = var.notification_slack_channel_prefix
  tag_slack_channel                 = var.tag_slack_channel
  environment                       = var.environment
  service                           = "http_check"

  monitors = {
    for monitor, config in local.default_http_check_monitors :
    monitor => merge(config, try(var.override_default_monitors[monitor], {})) if var.http_check_enabled
  }
}
