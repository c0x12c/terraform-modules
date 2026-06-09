module "service_monitor" {
  source = "../../"

  cluster_name                      = "proj-service-dev"
  service_name                      = "service-platform"
  environment                       = "dev"
  tag_slack_channel                 = false
  notification_slack_channel_prefix = "proj-service-x-"

  pod_monitor_enabled     = true
  cpu_monitor_enabled     = true
  memory_monitor_enabled  = true
  service_monitor_enabled = true

  override_default_monitors = {
    error_hit = {
      priority_level = 3
      title_tags     = "[High Error Hits]"
      title          = "Service service-platform Error Hits is high"
      query_template = "sum($${timeframe}):sum:$${metric}{env:dev,service:service-platform}.as_count() > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
        metric    = "trace.fastapi.request.errors"
      }

      threshold_critical          = 1
      threshold_critical_recovery = 0
      renotify_interval           = 60
    }

    # Partial override: set only the fields you want to change; title,
    # query_template, and the rest keep their module defaults.
    p95 = {
      threshold_critical          = 2
      threshold_critical_recovery = 1.8
    }
  }
}
