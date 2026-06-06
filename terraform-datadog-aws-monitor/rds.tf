module "rds" {
  source  = "c0x12c/monitors/datadog"
  version = "~> 1.0.0"

  notification_slack_channel_prefix = var.notification_slack_channel_prefix
  tag_slack_channel                 = var.tag_slack_channel
  environment                       = var.environment
  service                           = "rds"

  monitors = {
    for monitor, config in local.default_rds_monitors :
    monitor => merge(config, try(var.override_default_monitors[monitor], {})) if contains(var.enabled_modules, "rds")
  }
}

locals {
  default_rds_monitors = {
    rds_cpu = {
      priority_level = 2
      title_tags     = "[High CPU Utilization] [RDS]"
      title          = "RDS CPU Utilization is too high."

      query_template = "avg($${timeframe}):avg:aws.rds.cpuutilization{aws_account:${var.aws_account_id}, dbinstanceidentifier:${var.db_name_regex}} by {dbinstanceidentifier} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 80
      threshold_critical_recovery = 70
      renotify_interval           = 30
      renotify_occurrences        = 3
    }

    rds_cpu_o1 = {
      priority_level = 3
      title_tags     = "[High CPU Utilization] [RDS]"
      title          = "RDS CPU Utilization is high."

      query_template = "avg($${timeframe}):avg:aws.rds.cpuutilization{aws_account:${var.aws_account_id}, dbinstanceidentifier:${var.db_name_regex}} by {dbinstanceidentifier} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 70
      threshold_critical_recovery = 50
      renotify_interval           = 50
      renotify_occurrences        = 3
    }

    rds_storage = {
      priority_level = 2
      title_tags     = "[High Storage Utilization] [RDS]"
      title          = "RDS Storage Utilization is too high."

      query_template = "avg($${timeframe}):100 - ((avg:aws.rds.free_storage_space{aws_account:${var.aws_account_id}, dbinstanceidentifier:${var.db_name_regex}} by {dbinstanceidentifier,engine} / avg:aws.rds.total_storage_space{aws_account:${var.aws_account_id}} by {dbinstanceidentifier,engine}) * 100) > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 80
      threshold_critical_recovery = 70
      renotify_interval           = 30
      renotify_occurrences        = 3
      require_full_window         = false
    }

    rds_storage_o1 = {
      priority_level = 3
      title_tags     = "[High Storage Utilization] [RDS]"
      title          = "RDS Storage Utilization is high."

      query_template = "avg($${timeframe}):100 - ((avg:aws.rds.free_storage_space{aws_account:${var.aws_account_id}, dbinstanceidentifier:${var.db_name_regex}} by {dbinstanceidentifier,engine} / avg:aws.rds.total_storage_space{aws_account:${var.aws_account_id}} by {dbinstanceidentifier,engine}) * 100) > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 70
      threshold_critical_recovery = 50
      renotify_interval           = 50
      renotify_occurrences        = 3
      require_full_window         = false
    }

    rds_query_p95 = {
      priority_level = 2
      title_tags     = "[High P95 latency] [RDS]"
      title          = "RDS Query has a tremendous high P95 latency"

      query_template = "percentile($${timeframe}):p95:trace.postgres.query{env:${var.environment}, dbinstanceidentifier:${var.db_name_regex}} by {resource_name} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 0.4
      threshold_critical_recovery = 0.3
      renotify_interval           = 30
      renotify_occurrences        = 3
    }

    rds_query_hits = {
      priority_level = 5
      title_tags     = "[High Query Hits] [RDS]"
      title          = "RDS Query Hits is high"

      query_template = "sum($${timeframe}):sum:trace.postgres.query.hits{env:${var.environment}, dbinstanceidentifier:${var.db_name_regex}}.as_count() > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      override_default_message = "RDS Query Hits is high"

      threshold_critical          = 5000
      threshold_critical_recovery = 3000
      renotify_interval           = 60
      renotify_occurrences        = 3
    }

    rds_query_errors = {
      priority_level = 3
      title_tags     = "[High Query Errors] [RDS]"
      title          = "RDS Query Errors is high"

      query_template = "sum($${timeframe}):sum:trace.postgres.query.errors{env:${var.environment}, dbinstanceidentifier:${var.db_name_regex}}.as_count() > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 5
      threshold_critical_recovery = 0
      renotify_interval           = 50
      renotify_occurrences        = 3
    }
  }
}
