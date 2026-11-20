terraform {
  required_version = ">= 1.9.8"

  required_providers {
    # Upper bound: a major aws provider release can change the service quota schema.
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75, < 7.0"
    }
  }
}
