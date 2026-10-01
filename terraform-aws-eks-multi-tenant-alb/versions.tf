terraform {
  required_version = ">= 1.9.8"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.75"
      configuration_aliases = [aws.us_east_1]
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.33"
    }
  }
}
