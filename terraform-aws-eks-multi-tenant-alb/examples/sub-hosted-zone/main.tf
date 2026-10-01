provider "aws" {
  region = "us-west-2"
}

# The parent zone already exists; the module creates one sub-zone per tenant inside it
# and writes the NS delegation back into this parent zone.
data "aws_route53_zone" "parent" {
  name         = "example.com."
  private_zone = false
}

module "eks_multi_tenant_alb" {
  source = "../../"

  name   = "example-tenant"
  domain = "example.com"

  # Required when create_hosted_zone is true, so the sub-zone apex is <tenant>.<domain>.
  host_template = "{service}.{tenant}"
  tenants       = ["acme", "globex"]

  services = {
    auth          = { namespace = "service-auth", name = "service-auth", port = 80 }
    rental        = { namespace = "service-rental", name = "service-rental", port = 80, health_check_path = "/actuator/health" }
    web-dashboard = { namespace = "web-dashboard", name = "web-dashboard", port = 80 }
  }

  # One sub-zone per tenant (acme.example.com, globex.example.com), with NS delegation written back to the parent.
  create_hosted_zone = true
  parent_zone_id     = data.aws_route53_zone.parent.zone_id

  # us-west-2 certificates for the ALB, each with the apex SAN (<tenant>.example.com) alongside the wildcard
  # (*.<tenant>.example.com). CloudFront's us-east-1 copy is issued in the consumer stack.
  create_certificates          = true
  include_apex_in_certificates = true

  # Helm charts own the service ingresses: each service's chart renders its own ingress with
  # alb.ingress.kubernetes.io/group.name = "example-tenant" to attach to this ALB.
  create_service_ingresses = false

  # Tenant apex (acme.example.com, globex.example.com) points at the webapp CloudFront distribution.
  webapp_alias_target = {
    name    = "d111111abcdef8.cloudfront.net"
    zone_id = "Z2FDTNDATAQYW2"
  }

  tags = {
    Environment = "dev"
  }
}
