module "ecs_monitors" {
  source = "../../"

  aws_account_id   = "123456789012"
  environment      = "prod"
  ecs_cluster_name = "my-cluster"
  ecs_service_name = "my-api-service"

  notification_slack_channel_prefix = "alerts-"
  tag_slack_channel                 = true
  escalate_min_priority          = 2 # Only tag @channel for P1 and P2, not P3 (e.g., throughput drop)

  enabled_monitors = ["service", "apm"]

  apm_service_name = "my-api-service"
  apm_http_metric  = "trace.http.request"

  cpu_critical_threshold    = 85
  cpu_warning_threshold     = 75
  memory_critical_threshold = 85
  memory_warning_threshold  = 75
  p95_latency_threshold     = 0.5
  error_rate_threshold      = 0.5
}

module "ecs_monitors_all_services" {
  source = "../../"

  aws_account_id   = "123456789012"
  environment      = "prod"
  ecs_cluster_name = "my-cluster"
  ecs_service_name = "*"

  notification_slack_channel_prefix = "alerts-"
  tag_slack_channel                 = true

  enabled_monitors = ["service"]

  override_default_monitors = {
    service_cpu_high = {
      threshold_critical = 90
      renotify_interval  = 20
    }
  }
}
