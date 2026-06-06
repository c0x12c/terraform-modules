terraform {
  required_version = ">= 1.9.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.12"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.12"
    }
  }
}
