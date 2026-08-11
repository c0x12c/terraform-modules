provider "aws" {
  region = "us-west-2"
}

# Global events (IAM and friends) are delivered to us-east-1 only.
provider "aws" {
  alias  = "global"
  region = "us-east-1"
}

# Rule and topic only — no slack_channels. A Slack channel accepts one Chatbot
# configuration per account, so this topic is subscribed by the primary
# instance below instead of getting its own.
module "health_notification_global" {
  source = "../../"

  providers = {
    aws = aws.global
  }

  name = "example-global"

  event_type_categories = ["issue", "scheduledChange"]
  exclude_backup_events = true
}

module "health_notification" {
  source = "../../"

  name = "example"

  event_type_categories = ["issue", "scheduledChange"]

  # Both Regions back up the other, so without this every event alerts twice.
  exclude_backup_events = true

  additional_sns_topic_arns = [module.health_notification_global.sns_topic_arn]

  slack_channels = {
    alerts = {
      workspace_id = "T0XXXXXXX"
      channel_id   = "C0XXXXXXX"
    }
  }

  subscriptions = {
    oncall_email = {
      protocol = "email"
      endpoint = "oncall@example.com"
    }
  }

  tags = {
    Environment = "dev"
  }
}
