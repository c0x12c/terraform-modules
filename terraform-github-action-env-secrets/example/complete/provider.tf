terraform {
  required_version = ">= 1.9.8"

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.4.0"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
