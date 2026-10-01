provider "aws" {
  region = "us-west-2"
}

module "eks_multi_tenant_alb" {
  source = "../../"

  name    = "example-tenant"
  domain  = "example.com"
  zone_id = "Z0123456789EXAMPLE"

  # Every tenant gets one host per service: auth.acme.example.com, rental.globex.example.com, ...
  tenants       = ["acme", "globex"]
  host_template = "{service}.{tenant}"

  services = {
    auth   = { namespace = "service-auth", name = "service-auth", port = 80 }
    rental = { namespace = "service-rental", name = "service-rental", port = 80, health_check_path = "/actuator/health" }
  }

  # One certificate per tenant: *.acme.example.com + acme.example.com (apex SAN), same for globex. Plus one A record per host.
  create_certificates = true
  certificate_arns    = []
  create_dns_records  = true

  security_group_ids = ["sg-0123456789abcdef0"]
  access_logs_bucket = "example-alb-access-logs"
  wafv2_arn          = null # set a WAFv2 web ACL ARN to protect the ALB

  tags = {
    Environment = "dev"
  }
}
