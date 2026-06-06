module "billing" {
  source  = "c0x12c/monitors/datadog"
  version = "~> 1.0.0"

  notification_slack_channel_prefix = var.notification_slack_channel_prefix
  tag_slack_channel                 = var.tag_slack_channel
  environment                       = var.environment
  service                           = "billing"

  monitors = {
    for monitor, config in local.default_billing_monitors :
    monitor => merge(config, try(var.override_default_monitors[monitor], {})) if contains(var.enabled_modules, "billing")
  }
}

locals {
  default_billing_monitors = {
    aws_actual_spend = {
      priority_level = 3
      title_tags     = "[High Actual Spend] [AWS Billing]"
      title          = "AWS Billing actual spend exceeds threshold."

      query_template = "max($${timeframe}):max:aws.billing.actual_spend{aws_account:${var.aws_account_id}} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 300
      threshold_critical_recovery = 0
      renotify_interval           = 10
      renotify_occurrences        = 1
    }

    aws_forecasted_spend = {
      priority_level = 3
      title_tags     = "[High Forecasted Spend] [AWS Billing]"
      title          = "AWS Billing forecasted spend exceeds threshold."

      query_template = "max($${timeframe}):max:aws.billing.forecasted_spend{aws_account:${var.aws_account_id}} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 350
      threshold_critical_recovery = 0
      renotify_interval           = 10
      renotify_occurrences        = 1
    }
  }
}
