terraform {
  required_version = ">= 1.9.8"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.33"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">=2.16.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75.0"
    }
  }
}
