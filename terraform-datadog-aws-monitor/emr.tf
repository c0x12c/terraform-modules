module "emr" {
  source  = "c0x12c/monitors/datadog"
  version = "~> 1.0.0"

  notification_slack_channel_prefix = var.notification_slack_channel_prefix
  tag_slack_channel                 = var.tag_slack_channel
  environment                       = var.environment
  service                           = "emr"
  monitors = {
    for monitor, config in local.default_emr_monitors :
    monitor => merge(config, try(var.override_default_monitors[monitor], {})) if contains(var.enabled_modules, "emr")
  }
}

locals {
  default_emr_monitors = {
    spark_job_failed = {
      priority_level = 1
      title_tags     = "[Job failed] [Spark]"
      title          = "Spark Job Failures is detected."

      query_template = "sum($${timeframe}):sum:aws.emrserverless.failed_jobs{environment:${var.environment}} > $${threshold_critical}"
      query_args = {
        timeframe = "last_1h"
      }

      threshold_critical   = 0
      renotify_interval    = 60
      renotify_occurrences = 3
    }
  }
}
