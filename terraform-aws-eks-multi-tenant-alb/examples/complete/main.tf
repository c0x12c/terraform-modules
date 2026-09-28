provider "aws" {
  region = "us-west-2"
}

module "eks_multi_tenant_alb" {
  source = "../../"

  name    = "example-tenant"
  domain  = "example.com"
  zone_id = "Z0123456789EXAMPLE"

  tenant_hosts = {
    acme = {
      auth   = "auth.acme"
      rental = "rental.acme"
    }
  }

  services = {
    auth   = { namespace = "service-auth", name = "service-auth", port = 80 }
    rental = { namespace = "service-rental", name = "service-rental", port = 80 }
  }

  security_group_ids = ["sg-0123456789abcdef0"]
  access_logs_bucket = "example-alb-access-logs"

  tags = {
    Environment = "dev"
  }
}
