terraform {
  required_version = ">= 1.9.8"

  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.46.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 6.12"
    }
  }
}
