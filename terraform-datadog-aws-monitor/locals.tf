locals {
  notifiers                = "@slack-${var.notification_slack_channel_prefix}${var.environment}"
  message                  = var.environment == "prod" ? "${local.notifiers} <!channel>" : "${local.notifiers}"
  notification_preset_name = "hide_all"
  enabled_include_tags     = false
}
