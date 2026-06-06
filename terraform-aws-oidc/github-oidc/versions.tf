terraform {
  required_version = ">= 1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.6"
    }
  }
}
