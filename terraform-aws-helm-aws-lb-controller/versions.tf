terraform {
  required_version = ">= 1.9.8"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.33"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75.0"
    }
  }
}
