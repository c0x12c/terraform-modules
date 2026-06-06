terraform {
  required_version = ">= 1.9.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.12"
    }

    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.46"
    }
  }
}
