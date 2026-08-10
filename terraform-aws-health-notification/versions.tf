terraform {
  required_version = ">= 1.9.8"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # aws_chatbot_slack_channel_configuration landed in 5.61.
      version = ">= 5.61, < 7.0.0"
    }
  }
}
