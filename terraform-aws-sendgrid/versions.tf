terraform {
  required_version = ">= 1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75"
    }

    sendgrid = {
      source  = "anna-money/sendgrid"
      version = ">= 1.0.5"
    }
  }
}
