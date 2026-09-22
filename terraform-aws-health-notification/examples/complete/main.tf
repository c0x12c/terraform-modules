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

  enable_heartbeat      = true
  enable_delivery_alarm = true
  # Off by default: the failure metric is absent on a healthy topic, so OK actions would post a
  # "nothing is wrong" message on creation and after every incident.
  enable_ok_actions = false

  tags = {
    Environment = "dev"
  }
}
