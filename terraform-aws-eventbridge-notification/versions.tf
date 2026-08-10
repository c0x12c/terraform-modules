terraform {
  required_version = ">= 1.9.8"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # aws_chatbot_teams_channel_configuration landed in 5.62.
      version = ">= 5.62, < 7.0.0"
    }
  }
}
