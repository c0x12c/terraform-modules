terraform {
  required_version = ">= 1.9.8"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.34"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.12"
    }
  }
}
