locals {
  apm_service          = coalesce(var.apm_service_name, var.ecs_service_name)
  p99_threshold        = coalesce(var.p99_latency_threshold, var.p95_latency_threshold * 3)
  service_display_name = var.ecs_service_name != "*" ? var.ecs_service_name : "All Services"
  ecs_filter           = "aws_account:${var.aws_account_id},environment:${var.environment},clustername:${var.ecs_cluster_name}"
  service_filter       = var.ecs_service_name != "*" ? ",servicename:${var.ecs_service_name}" : ""
  recovery_ratio       = var.recovery_threshold_ratio

  # Notification message generation based on priority level and minimum threshold
  notifiers = "@slack-${var.notification_slack_channel_prefix}${var.environment}"
  notification_message = {
    for priority in [1, 2, 3] :
    priority => format("%s%s", local.notifiers, var.tag_slack_channel && (var.escalate_min_priority == 0 || priority <= var.escalate_min_priority) ? " <!channel>" : "")
  }

  # Service Monitors
  default_service_monitors = {
    service_cpu_high = {
      enabled                  = true
      priority_level           = 2
      title_tags               = "[High CPU] [ECS Service] [${local.service_display_name}]"
      title                    = "CPU utilization is high"
      override_default_message = local.notification_message[2]

      query_template = "avg($${timeframe}):avg:aws.ecs.service.cpuutilization{${local.ecs_filter}${local.service_filter}} by {servicename} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = var.cpu_critical_threshold
      threshold_critical_recovery = var.cpu_critical_threshold * local.recovery_ratio
      threshold_warning           = var.cpu_warning_threshold
      threshold_warning_recovery  = var.cpu_warning_threshold * local.recovery_ratio
      renotify_interval           = var.renotify_interval_high
      renotify_occurrences        = 3
    }

    service_cpu_critical = {
      enabled                  = true
      priority_level           = 1
      title_tags               = "[Critical CPU] [ECS Service] [${local.service_display_name}]"
      title                    = "CPU utilization is critical"
      override_default_message = local.notification_message[1]

      query_template = "avg($${timeframe}):avg:aws.ecs.service.cpuutilization{${local.ecs_filter}${local.service_filter}} by {servicename} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = var.cpu_critical_max_threshold
      threshold_critical_recovery = var.cpu_critical_max_threshold * local.recovery_ratio
      renotify_interval           = var.renotify_interval_critical
      renotify_occurrences        = 5
    }

    service_memory_high = {
      enabled                  = true
      priority_level           = 2
      title_tags               = "[High Memory] [ECS Service] [${local.service_display_name}]"
      title                    = "Memory utilization is high"
      override_default_message = local.notification_message[2]

      query_template = "avg($${timeframe}):avg:aws.ecs.service.memory_utilization{${local.ecs_filter}${local.service_filter}} by {servicename} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = var.memory_critical_threshold
      threshold_critical_recovery = var.memory_critical_threshold * local.recovery_ratio
      threshold_warning           = var.memory_warning_threshold
      threshold_warning_recovery  = var.memory_warning_threshold * local.recovery_ratio
      renotify_interval           = var.renotify_interval_high
      renotify_occurrences        = 3
    }

    service_memory_critical = {
      enabled                  = true
      priority_level           = 1
      title_tags               = "[Critical Memory] [ECS Service] [${local.service_display_name}]"
      title                    = "Memory utilization is critical - OOM risk"
      override_default_message = local.notification_message[1]

      query_template = "avg($${timeframe}):avg:aws.ecs.service.memory_utilization{${local.ecs_filter}${local.service_filter}} by {servicename} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = var.memory_critical_max_threshold
      threshold_critical_recovery = var.memory_critical_max_threshold * local.recovery_ratio
      renotify_interval           = var.renotify_interval_critical
      renotify_occurrences        = 5
    }

    service_running_tasks_low = {
      enabled                  = true
      priority_level           = 1
      title_tags               = "[Low Running Tasks] [ECS Service] [${local.service_display_name}]"
      title                    = "Fewer running tasks than desired"
      override_default_message = local.notification_message[1]

      query_template = "avg($${timeframe}):avg:aws.ecs.service.running{${local.ecs_filter}${local.service_filter}} by {servicename} - avg:aws.ecs.service.desired{${local.ecs_filter}${local.service_filter}} by {servicename} < $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = -1
      threshold_critical_recovery = 0
      renotify_interval           = var.renotify_interval_critical
      renotify_occurrences        = 5
      require_full_window         = false
    }

    service_task_count_zero = {
      enabled                  = true
      priority_level           = 1
      title_tags               = "[Service Down] [ECS Service] [${local.service_display_name}]"
      title                    = "ECS Service has no running tasks"
      override_default_message = local.notification_message[1]

      query_template = "max($${timeframe}):sum:aws.ecs.service.running{${local.ecs_filter}${local.service_filter}} by {servicename} <= $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical   = 0
      renotify_interval    = 10
      renotify_occurrences = 10
      require_full_window  = false
    }

    service_pending_tasks_stuck = {
      enabled                  = true
      priority_level           = 2
      title_tags               = "[Pending Tasks] [ECS Service] [${local.service_display_name}]"
      title                    = "ECS Service has tasks stuck in pending state"
      override_default_message = local.notification_message[2]

      query_template = "min($${timeframe}):sum:aws.ecs.service.pending{${local.ecs_filter}${local.service_filter}} by {servicename} > $${threshold_critical}"
      query_args = {
        timeframe = "last_10m"
      }

      threshold_critical   = 1
      renotify_interval    = var.renotify_interval_high
      renotify_occurrences = 3
    }
  }

  # Log Monitors
  default_log_monitors = {
    log_error_spike = {
      enabled                  = true
      priority_level           = 2
      type                     = "log alert"
      title_tags               = "[Error Spike] [Logs] [${local.service_display_name}]"
      title                    = "High volume of error logs detected"
      override_default_message = local.notification_message[2]

      query_template = "logs(\"service:${local.apm_service} status:error env:${var.environment}\").index(\"*\").rollup(\"count\").last(\"$${timeframe}\") > $${threshold_critical}"
      query_args = {
        timeframe = "15m"
      }

      threshold_critical          = var.log_error_count_threshold
      threshold_critical_recovery = var.log_error_count_threshold * local.recovery_ratio
      threshold_warning           = var.log_error_count_threshold * 0.5
      threshold_warning_recovery  = var.log_error_count_threshold * 0.4
      renotify_interval           = var.renotify_interval_high
      renotify_occurrences        = 3
      require_full_window         = true
    }

    log_critical_errors = {
      enabled                  = true
      priority_level           = 1
      type                     = "log alert"
      title_tags               = "[Critical Errors] [Logs] [${local.service_display_name}]"
      title                    = "Critical error logs detected (5xx/fatal/panic)"
      override_default_message = local.notification_message[1]

      query_template = "logs(\"service:${local.apm_service} (status:critical OR status:emergency OR @http.status_code:[500 TO 599] OR @level:fatal OR @level:panic) env:${var.environment}\").index(\"*\").rollup(\"count\").last(\"$${timeframe}\") > $${threshold_critical}"
      query_args = {
        timeframe = "10m"
      }

      threshold_critical          = var.log_critical_error_threshold
      threshold_critical_recovery = 0
      renotify_interval           = var.renotify_interval_critical
      renotify_occurrences        = 5
      require_full_window         = false
    }

    log_sustained_errors = {
      enabled                  = true
      priority_level           = 2
      type                     = "log alert"
      title_tags               = "[Sustained Errors] [Logs] [${local.service_display_name}]"
      title                    = "Sustained high error volume over extended period"
      override_default_message = local.notification_message[2]

      query_template = "logs(\"service:${local.apm_service} status:error env:${var.environment}\").index(\"*\").rollup(\"count\").last(\"$${timeframe}\") > $${threshold_critical}"
      query_args = {
        timeframe = "1h"
      }

      threshold_critical          = var.log_sustained_error_threshold
      threshold_critical_recovery = var.log_sustained_error_threshold * local.recovery_ratio
      renotify_interval           = var.renotify_interval_high
      renotify_occurrences        = 3
      require_full_window         = true
    }
  }

  # APM Monitors
  default_apm_monitors = {
    apm_p95_latency = {
      enabled                  = true
      priority_level           = 3
      title_tags               = "[High P95 Latency] [APM] [${local.apm_service}]"
      title                    = "Service ${local.apm_service} P95 latency is high"
      override_default_message = local.notification_message[3]

      query_template = "percentile($${timeframe}):p95:$${metric}{env:${var.environment},service:${local.apm_service}} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
        metric    = var.apm_http_metric
      }

      threshold_critical          = var.p95_latency_threshold
      threshold_critical_recovery = var.p95_latency_threshold * local.recovery_ratio
      renotify_interval           = var.renotify_interval_medium
      renotify_occurrences        = 2
    }

    apm_p99_latency = {
      enabled                  = true
      priority_level           = 2
      title_tags               = "[High P99 Latency] [APM] [${local.apm_service}]"
      title                    = "Service ${local.apm_service} P99 latency is high"
      override_default_message = local.notification_message[2]

      query_template = "percentile($${timeframe}):p99:$${metric}{env:${var.environment},service:${local.apm_service}} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
        metric    = var.apm_http_metric
      }

      threshold_critical          = local.p99_threshold
      threshold_critical_recovery = local.p99_threshold * local.recovery_ratio
      renotify_interval           = var.renotify_interval_high
      renotify_occurrences        = 3
    }

    apm_error_rate = {
      enabled                  = true
      priority_level           = 2
      title_tags               = "[High Error Rate] [APM] [${local.apm_service}]"
      title                    = "Service ${local.apm_service} error rate is high"
      override_default_message = local.notification_message[2]

      query_template = "sum($${timeframe}):(sum:$${metric}.errors{env:${var.environment},service:${local.apm_service}}.as_count() / sum:$${metric}.hits{env:${var.environment},service:${local.apm_service}}.as_count()) * 100 > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
        metric    = var.apm_http_metric
      }

      threshold_critical          = var.error_rate_threshold
      threshold_critical_recovery = var.error_rate_threshold * local.recovery_ratio
      renotify_interval           = var.renotify_interval_high
      renotify_occurrences        = 3
      require_full_window         = false
    }

    apm_error_count = {
      enabled                  = true
      priority_level           = 2
      title_tags               = "[Error Spike] [APM] [${local.apm_service}]"
      title                    = "Service ${local.apm_service} error count is high"
      override_default_message = local.notification_message[2]

      query_template = "sum($${timeframe}):sum:$${metric}.errors{env:${var.environment},service:${local.apm_service}}.as_count() > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
        metric    = var.apm_http_metric
      }

      threshold_critical          = var.error_count_threshold
      threshold_critical_recovery = var.error_count_threshold * local.recovery_ratio
      renotify_interval           = var.renotify_interval_high
      renotify_occurrences        = 3
    }

    apm_throughput_drop = {
      enabled                  = true
      priority_level           = 3
      title_tags               = "[Throughput Drop] [APM] [${local.apm_service}]"
      title                    = "Service ${local.apm_service} request throughput dropped significantly"
      override_default_message = local.notification_message[3]

      query_template = "change(sum($${timeframe}),last_1h):sum:$${metric}.hits{env:${var.environment},service:${local.apm_service}}.as_count() < $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
        metric    = var.apm_http_metric
      }

      threshold_critical          = -50
      threshold_critical_recovery = -30
      renotify_interval           = var.renotify_interval_medium
      renotify_occurrences        = 2
      require_full_window         = false
    }
  }
}
