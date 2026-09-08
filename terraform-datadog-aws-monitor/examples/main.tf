module "aws_monitor" {
  source = "../"

  environment       = "prod"
  tag_slack_channel = true

  aws_account_id                    = "123456789012"
  notification_slack_channel_prefix = "prj-service-x-"

  override_default_monitors = {
    aws_actual_spend = {
      threshold_critical = 500
      additional_tags    = ["team:platform"]
    }
    rds_query_hits = {
      enabled = false
    }
    rds_cpu = {
      additional_tags = ["team:platform"]
    }
  }

  enabled_modules = ["billing", "rds"]
}
