terraform {
  required_version = ">= 1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}
