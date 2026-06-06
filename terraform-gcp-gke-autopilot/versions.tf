terraform {
  required_version = ">= 1.9.8"

  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.12"
    }
  }
}
