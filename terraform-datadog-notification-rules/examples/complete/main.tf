locals {
  notification_rules = {
    prod_slack_rule = {
      name       = "Prod Slack Notification Rule"
      recipients = ["slack-prj-x-prod"]
      filter = {
        tags = ["env:prod"]
      }
    }
    # Rules only add recipients, so a shared channel excludes a team with NOT, which needs scope.
    dev_shared_rule = {
      name       = "Dev shared channel, every team except x"
      recipients = ["slack-ops-dev"]
      filter = {
        scope = "env:dev AND NOT team:x"
      }
    }
  }
}

module "datadog_notification_rules" {
  source = "../../"

  notification_rules = local.notification_rules
}
