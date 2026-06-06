module "msk" {
  source  = "c0x12c/monitors/datadog"
  version = "~> 1.0.0"

  notification_slack_channel_prefix = var.notification_slack_channel_prefix
  tag_slack_channel                 = var.tag_slack_channel
  environment                       = var.environment
  service                           = "msk"

  monitors = {
    for monitor, config in local.default_msk_monitors :
    monitor => merge(config, try(var.override_default_monitors[monitor], {})) if contains(var.enabled_modules, "msk")
  }
}

locals {
  default_msk_monitors = {
    msk_cpu = {
      priority_level = 2
      title_tags     = "[High CPU Utilization] [MSK]"
      title          = "MSK Broker CPU Utilization is too high."

      query_template = "avg($${timeframe}):avg:aws.kafka.cpu_user{aws_account:${var.aws_account_id}} by {cluster_name,broker_id} > $${threshold_critical}"
      query_args = {
        timeframe = "last_10m"
      }

      threshold_critical          = 80
      threshold_critical_recovery = 60
      renotify_interval           = 30
      renotify_occurrences        = 3
    }

    msk_cpu_o1 = {
      priority_level = 3
      title_tags     = "[High CPU Utilization] [MSK]"
      title          = "MSK Broker CPU Utilization is high."

      query_template = "avg($${timeframe}):avg:aws.kafka.cpu_user{aws_account:${var.aws_account_id}} by {cluster_name,broker_id} > $${threshold_critical}"
      query_args = {
        timeframe = "last_10m"
      }

      threshold_critical          = 60
      threshold_critical_recovery = 40
      renotify_interval           = 50
      renotify_occurrences        = 3
    }

    msk_disk_used = {
      priority_level = 2
      title_tags     = "[High Disk Usage] [MSK]"
      title          = "MSK Broker Disk Usage is too high."

      query_template = "avg($${timeframe}):avg:aws.kafka.kafka_data_logs_disk_used{aws_account:${var.aws_account_id}} by {cluster_name,broker_id} > $${threshold_critical}"
      query_args = {
        timeframe = "last_10m"
      }

      threshold_critical          = 80
      threshold_critical_recovery = 60
      renotify_interval           = 30
      renotify_occurrences        = 3
    }

    msk_disk_used_o1 = {
      priority_level = 3
      title_tags     = "[High Disk Usage] [MSK]"
      title          = "MSK Broker Disk Usage is high."

      query_template = "avg($${timeframe}):avg:aws.kafka.kafka_data_logs_disk_used{aws_account:${var.aws_account_id}} by {cluster_name,broker_id} > $${threshold_critical}"
      query_args = {
        timeframe = "last_10m"
      }

      threshold_critical          = 60
      threshold_critical_recovery = 40
      renotify_interval           = 50
      renotify_occurrences        = 3
    }

    msk_offline_partitions = {
      priority_level = 1
      title_tags     = "[Offline Partitions] [MSK]"
      title          = "MSK has offline partitions."

      query_template = "avg($${timeframe}):sum:aws.kafka.offline_partitions_count{aws_account:${var.aws_account_id}} by {cluster_name} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 1
      threshold_critical_recovery = 0
      renotify_interval           = 10
      renotify_occurrences        = 5
    }

    msk_active_controller = {
      priority_level = 2
      title_tags     = "[Active Controller] [MSK]"
      title          = "MSK Active Controller Count is abnormal."

      query_template = "avg($${timeframe}):avg:aws.kafka.active_controller_count{aws_account:${var.aws_account_id}} by {cluster_name} < $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 1
      threshold_critical_recovery = 2
      renotify_interval           = 10
      renotify_occurrences        = 5
    }
  }
}
