module "pod" {
  source = "../terraform-datadog-monitors"

  notification_slack_channel_prefix = var.notification_slack_channel_prefix
  tag_slack_channel                 = var.tag_slack_channel
  environment                       = var.environment
  service                           = "k8s"

  monitors = {
    for monitor, config in local.default_pod_monitors :
    monitor => merge(config, try(var.override_default_monitors[monitor], {})) if var.pod_monitor_enabled
  }
}
