terraform {
  required_version = ">= 1.9.8"

  required_providers {
    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = ">= 0.7.0"
    }
  }
}
