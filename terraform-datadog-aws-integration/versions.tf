terraform {
  required_version = ">= 1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75"
    }

    datadog = {
      source  = "DataDog/datadog"
      version = "~> 4.9.0"
    }
  }
}
