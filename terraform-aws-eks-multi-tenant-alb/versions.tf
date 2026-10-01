terraform {
  required_version = ">= 1.9.8"

  required_providers {
    # 6.0 adds the per-resource region argument, used for the us-east-1 CloudFront certificates.
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.33"
    }
  }
}
