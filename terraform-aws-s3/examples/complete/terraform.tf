terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.23.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
