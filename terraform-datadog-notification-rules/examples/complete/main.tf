locals {
  notification_rules = {
    prod_slack_rule = {
      name       = "Prod Slack Notification Rule"
      recipients = ["slack-prj-x-prod"]
      filter = {
        tags = ["env:prod"]
      }
    }
    # Rules only add recipients, so a shared channel excludes a project with NOT, which needs scope.
    dev_shared_rule = {
      name       = "Dev shared channel, every project except x"
      recipients = ["slack-ops-dev"]
      filter = {
        scope = "env:dev AND NOT project:x"
      }
    }
  }
}

module "datadog_notification_rules" {
  source = "../../"

  notification_rules = local.notification_rules
}
