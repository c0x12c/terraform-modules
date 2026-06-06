terraform {
  required_version = ">= 1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.5.0, < 6.11.2"
    }
  }
}
