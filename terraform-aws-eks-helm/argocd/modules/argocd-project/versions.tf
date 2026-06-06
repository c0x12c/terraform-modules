terraform {
  required_version = ">= 1.10"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.33.0"
    }
  }
}
