module "gcp_monitor" {
  source = "../.."

  notification_slack_channel_prefix = "project-x-alerts-"
  tag_slack_channel                 = true
  environment                       = "dev"

  override_default_monitors = {
    postgres_uptime_monitor = {
      priority_level           = 1
      title_tags               = "[Uptime] [PostgreSQL]"
      title                    = "GCP - PostgreSQL - Database is not healthy."
      override_default_message = "@ops-gennie-alerts @oncall-team" # default message mention slack channel

      query_template = "min($${timeframe}):sum:gcp.cloudsql.database.uptime{project_id:project-x} by {database_id} < $${threshold_critical}"
      query_args = {
        timeframe = "last_1m"
      }

      threshold_critical          = 55
      threshold_critical_recovery = 59
      renotify_interval           = 10
    }
  }
  postgres_monitor_enabled = true
}