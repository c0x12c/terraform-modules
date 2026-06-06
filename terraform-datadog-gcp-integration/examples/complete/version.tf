terraform {
  required_version = "~> 1.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.2"
    }

    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.66"
    }
  }
}
