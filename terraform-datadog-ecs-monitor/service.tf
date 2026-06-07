module "service_monitors" {
  source = "../terraform-datadog-monitors"

  notification_slack_channel_prefix = var.notification_slack_channel_prefix
  tag_slack_channel                 = var.tag_slack_channel
  environment                       = var.environment
  service                           = "ecs-service"

  monitors = {
    for monitor, config in local.default_service_monitors :
    monitor => merge(config, try(var.override_default_monitors[monitor], {}))
    if contains(var.enabled_monitors, "service")
  }
}
