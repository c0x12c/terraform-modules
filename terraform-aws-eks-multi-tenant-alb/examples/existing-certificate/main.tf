provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "eks_multi_tenant_alb" {
  source = "../../"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  name   = "example-tenant"
  domain = "example.com"

  # Hosts one level under the domain (acme-auth.example.com), so an existing *.example.com certificate covers them.
  tenants       = ["acme"]
  host_template = "{tenant}-{service}"

  services = {
    auth = { namespace = "service-auth", name = "service-auth", port = 80 }
  }

  # Use a certificate you already have, and manage DNS elsewhere: no zone_id is needed.
  create_certificates = false
  certificate_arns    = ["arn:aws:acm:us-west-2:123456789012:certificate/00000000-0000-0000-0000-000000000000"]
  create_dns_records  = false
}
