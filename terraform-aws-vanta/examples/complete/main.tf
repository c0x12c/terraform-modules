provider "aws" {
  region = "us-east-1"

  alias = "global"
}

module "vanta" {
  source = "../.."

  providers = {
    aws = aws.global
  }

  vanta_scanner_external_id = "GET_THIS_FROM_VANTA"
}
