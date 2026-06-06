module "monitor" {
  source = "../.."

  notification_slack_channel_prefix = "proj-service-x-"
  environment                       = "dev"
  tag_slack_channel                 = false
  service                           = "api-platform"

  monitors = {
    "http_5xx_rate_high" = {
      priority_level = 3
      title_tags     = "[HTTP 5xx Rate High] [API Platform]"
      title          = "HTTP 5xx Rate is too High"
      # override_default_message = "@ops-gennie-alerts @oncall-team"
      query_template = "avg($${timeframe}):sum:trace.http.request.errors{service:$${service},http.status_code:5*} by {service} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
        service   = "api-platform"
      }
      threshold_critical          = 30
      threshold_critical_recovery = 10
      renotify_interval           = 50
    }
  }
}
