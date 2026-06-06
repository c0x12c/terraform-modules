module "kinesis" {
  source  = "c0x12c/monitors/datadog"
  version = "~> 1.0.0"

  notification_slack_channel_prefix = var.notification_slack_channel_prefix
  tag_slack_channel                 = var.tag_slack_channel
  environment                       = var.environment
  service                           = "kinesis"

  monitors = {
    for monitor, config in local.default_kinesis_monitors :
    monitor => merge(config, try(var.override_default_monitors[monitor], {})) if contains(var.enabled_modules, "kinesis")
  }
}

locals {
  default_kinesis_monitors = {
    consumer_lag = {
      priority_level = 1
      title_tags     = "[Consumer Lag] [Kinesis]"
      title          = "Kinesis Consumer Lag is high."
      query_template = "max($${timeframe}):max:aws.kinesis.get_records_iterator_age{environment:${var.environment}} > $${threshold_critical}"
      query_args = {
        timeframe = "last_1h"
      }

      threshold_critical   = 300
      renotify_interval    = 60
      renotify_occurrences = 3
    }
    write_throttle = {
      priority_level = 1
      title_tags     = "[Write Throttle] [Kinesis]"
      title          = "Kinesis Write Throttle is high."
      query_template = "sum($${timeframe}):sum:aws.kinesis.write_provisioned_throughput_exceeded{environment:${var.environment}}.as_count() > $${threshold_critical}"
      query_args = {
        timeframe = "last_1h"
      }

      threshold_critical = 0
      renotify_interval  = 60
    }
    read_throttle = {
      priority_level = 1
      title_tags     = "[Read Throttle] [Kinesis]"
      title          = "Kinesis Read Throttle is high."
      query_template = "sum($${timeframe}):sum:aws.kinesis.read_provisioned_throughput_exceeded{environment:${var.environment}}.as_count() > $${threshold_critical}"
      query_args = {
        timeframe = "last_1h"
      }

      threshold_critical = 0
      renotify_interval  = 60
    }
  }
}
