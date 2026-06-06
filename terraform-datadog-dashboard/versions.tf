terraform {
  required_version = ">= 1.9.8"

  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.81.0"
    }
  }
}
