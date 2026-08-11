provider "aws" {
  region = "us-west-2"
}

module "health_notification" {
  source = "../../"

  name = "example"

  event_type_categories = ["issue", "scheduledChange"]

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
