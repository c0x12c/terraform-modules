module "mono_monitor" {
  source = "../../"

  notification_slack_channel_prefix = "proj-service-x-"
  environment                       = "dev"
  tag_slack_channel                 = false
  cluster_name                      = "proj-service-dev"

  pod_monitor_enabled = true
  http_check_enabled  = true

  override_default_monitors = {
    http_check = {
      priority_level           = 2
      title_tags               = "[HTTP Check]"
      title                    = "URLs are not healthy"
      override_default_message = "@oncall-team @slack-channel-prod"

      type           = "service check"
      query_template = "\"http.can_connect\".over(\"env:dev\").by(\"url\").last(2).count_by_status()"

      threshold_critical = 1
      ok                 = 1
      renotify_interval  = 60
    }
  }
}
