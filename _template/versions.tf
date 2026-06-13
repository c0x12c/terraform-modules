terraform {
  required_version = ">= 1.9.8"

  required_providers {
    # Replace with the provider(s) this module needs. Pin an upper bound when a
    # provider release can break the schema — a floating `>= x` can fail validate.
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75"
    }
  }
}
