terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.33"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75.0"
    }
  }
}
