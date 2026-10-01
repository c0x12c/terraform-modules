provider "aws" {
  region = "us-west-2"
}

module "eks_multi_tenant_alb" {
  source = "../../"

  name    = "example-tenant"
  domain  = "example.com"
  zone_id = "Z0123456789EXAMPLE"

  # One host rule, certificate and DNS record per service serve every tenant: *.auth.example.com
  # answers acme.auth.example.com, globex.auth.example.com, ... A new tenant needs no Terraform change.
  tenants       = ["*"]
  host_template = "{tenant}.{service}"

  services = {
    auth   = { namespace = "service-auth", name = "service-auth", port = 80 }
    rental = { namespace = "service-rental", name = "service-rental", port = 80 }
  }
}
