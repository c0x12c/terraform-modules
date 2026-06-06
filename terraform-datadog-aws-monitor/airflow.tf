module "airflow" {
  source  = "c0x12c/monitors/datadog"
  version = "~> 1.0.0"

  notification_slack_channel_prefix = var.notification_slack_channel_prefix
  tag_slack_channel                 = var.tag_slack_channel
  environment                       = var.environment
  service                           = "airflow"
  monitors = {
    for monitor, config in local.default_airflow_monitors :
    monitor => merge(config, try(var.override_default_monitors[monitor], {})) if contains(var.enabled_modules, "airflow")
  }
}

locals {
  default_airflow_monitors = {
    task_failed = {
      priority_level = 1
      title_tags     = "[Task failed] [Airflow]"
      title          = "Airflow Task Failures is detected."

      query_template = "sum($${timeframe}):sum:aws.mwaa.task_instance_finished{environment:${var.environment}, state:failed}.as_count() > $${threshold_critical}"
      query_args = {
        timeframe = "last_1h"
      }

      threshold_critical   = 0
      renotify_interval    = 60
      renotify_occurrences = 3
    }
  }
}
