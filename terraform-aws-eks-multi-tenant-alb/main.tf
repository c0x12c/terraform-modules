locals {
  # "acme/auth" => { tenant = "acme", service = "auth", host = "auth.acme.example.com" }
  routes = {
    for pair in setproduct(var.tenants, keys(var.services)) : "${pair[0]}/${pair[1]}" => {
      tenant  = pair[0]
      service = pair[1]
      host    = "${replace(replace(var.host_template, "{tenant}", pair[0]), "{service}", pair[1])}.${var.domain}"
    }
  }

  hosts = [for route in values(local.routes) : route.host]

  # A wildcard certificate covers one level only, so each host needs *.<its parent domain>:
  # auth.acme.example.com needs *.acme.example.com, and the wildcard host *.auth.example.com needs *.auth.example.com.
  certificate_domains = toset([for host in local.hosts : "*.${join(".", slice(split(".", host), 1, length(split(".", host))))}"])

  # Add the parent apex as a SAN (e.g. acme.example.com next to *.acme.example.com), except when the parent is the module's root domain.
  cert_sans = {
    for cert_domain in local.certificate_domains :
    cert_domain => (
      var.include_apex_in_certificates && trimprefix(cert_domain, "*.") != var.domain
      ) ? [
      trimprefix(cert_domain, "*.")
    ] : []
  }

  # Zone that holds the certificate validation CNAMEs for each cert. With create_hosted_zone,
  # host_template is pinned to "{service}.{tenant}" so the 2nd label of "*.<tenant>.<domain>" is the tenant.
  cert_zone_id = {
    for cert_domain in local.certificate_domains :
    cert_domain => var.create_hosted_zone ? aws_route53_zone.tenant[split(".", cert_domain)[1]].zone_id : var.zone_id
  }

  certificate_arns = concat(var.certificate_arns, [for cert in module.acm : cert.acm_certificate_arn])

  load_balancer_attributes = merge(
    {
      "deletion_protection.enabled"  = tostring(var.deletion_protection)
      "idle_timeout.timeout_seconds" = tostring(var.idle_timeout)
    },
    var.access_logs_bucket == null ? {} : {
      "access_logs.s3.enabled" = "true"
      "access_logs.s3.bucket"  = var.access_logs_bucket
    },
  )

  common_annotations = {
    "kubernetes.io/ingress.class"            = "alb"
    "alb.ingress.kubernetes.io/group.name"   = var.name
    "alb.ingress.kubernetes.io/scheme"       = var.scheme
    "alb.ingress.kubernetes.io/target-type"  = "ip"
    "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\": 443}]"
  }
}

# One sub-zone per tenant, named <tenant>.<domain>. Everything the module writes for a tenant
# (certificate validation, host records, webapp alias) lands in that zone.
resource "aws_route53_zone" "tenant" {
  for_each = var.create_hosted_zone ? toset(var.tenants) : toset([])

  name = "${each.key}.${var.domain}"
  tags = var.tags
}

# NS delegation in the parent zone. Without this, resolvers would not find the sub-zone.
resource "aws_route53_record" "tenant_delegation" {
  for_each = (var.create_hosted_zone && var.parent_zone_id != null) ? toset(var.tenants) : toset([])

  zone_id = var.parent_zone_id
  name    = "${each.key}.${var.domain}"
  type    = "NS"
  ttl     = var.hosted_zone_ns_ttl
  records = aws_route53_zone.tenant[each.key].name_servers
}

module "acm" {
  source   = "../terraform-aws-acm"
  for_each = var.create_certificates ? local.certificate_domains : toset([])

  zone_id                   = local.cert_zone_id[each.key]
  domain_name               = each.key
  subject_alternative_names = local.cert_sans[each.key]
  tags                      = var.tags

  # The HTTPS listener rejects a certificate that is not issued yet.
  wait_for_validation = true

  # Validation needs public DNS to resolve the CNAMEs. When the sub-zone is created here,
  # the parent-zone NS delegation must land first or ACM polls until it times out.
  depends_on = [aws_route53_record.tenant_delegation]
}

# CloudFront certificates (us-east-1) are left to the consumer: Terraform's `configuration_aliases`
# forces every caller of this module to pass an aws.us_east_1 alias, and the module CI validates
# the module standalone (without a root config) so declaring the alias here breaks the pipeline.
# The consumer can issue the matching cert in its own stack and attach it to CloudFront directly.

# Creates the ALB, its HTTPS listener with every certificate (SNI), and a default 404.
resource "kubernetes_ingress_v1" "alb" {
  # The Route53 records read the ALB hostname from this ingress's status.
  wait_for_load_balancer = true

  metadata {
    name      = var.name
    namespace = var.ingress_namespace

    annotations = merge(
      local.common_annotations,
      {
        "alb.ingress.kubernetes.io/load-balancer-name"       = var.name
        "alb.ingress.kubernetes.io/group.order"              = "1000"
        "alb.ingress.kubernetes.io/certificate-arn"          = join(",", local.certificate_arns)
        "alb.ingress.kubernetes.io/ssl-policy"               = var.ssl_policy
        "alb.ingress.kubernetes.io/load-balancer-attributes" = join(",", [for key, value in local.load_balancer_attributes : "${key}=${value}"])
        "alb.ingress.kubernetes.io/actions.response-404" = jsonencode({
          type                = "fixed-response"
          fixedResponseConfig = { contentType = "text/plain", statusCode = "404", messageBody = "Not found" }
        })
      },
      length(var.security_group_ids) > 0 ? { "alb.ingress.kubernetes.io/security-groups" = join(",", var.security_group_ids) } : {},
      length(var.tags) > 0 ? { "alb.ingress.kubernetes.io/tags" = join(",", [for key, value in var.tags : "${key}=${value}"]) } : {},
      var.wafv2_arn == null ? {} : { "alb.ingress.kubernetes.io/wafv2-acl-arn" = var.wafv2_arn },
    )
  }

  spec {
    rule {
      http {
        path {
          path = "/"
          backend {
            service {
              name = "response-404"
              port {
                name = "use-annotation"
              }
            }
          }
        }
      }
    }
  }

  # Checks that span several inputs. Preconditions rather than variable validations, so OpenTofu 1.8 runs them too.
  lifecycle {
    precondition {
      condition     = !contains(var.tenants, "*") || startswith(var.host_template, "{tenant}.")
      error_message = "A \"*\" tenant needs {tenant} as the whole leftmost label of host_template, e.g. \"{tenant}.{service}\": DNS and certificate wildcards only replace the leftmost label."
    }

    precondition {
      condition     = length(distinct(local.hosts)) == length(local.hosts)
      error_message = "Two routes get the same host. Change host_template, tenants or services so that every tenant and service pair has its own host."
    }

    precondition {
      condition     = var.create_hosted_zone || var.zone_id != null || (!var.create_certificates && !var.create_dns_records)
      error_message = "Set zone_id, enable create_hosted_zone, or set create_certificates and create_dns_records to false."
    }

    precondition {
      condition     = !var.create_hosted_zone || var.host_template == "{service}.{tenant}"
      error_message = "create_hosted_zone requires host_template = \"{service}.{tenant}\" so the sub-zone apex matches the tenant apex."
    }

    precondition {
      condition     = !var.create_hosted_zone || !contains(var.tenants, "*")
      error_message = "create_hosted_zone does not support the \"*\" wildcard tenant: a sub-zone needs a real tenant name."
    }

    precondition {
      condition     = !(var.create_hosted_zone && var.create_certificates) || var.parent_zone_id != null
      error_message = "Set parent_zone_id when create_hosted_zone and create_certificates are both true: ACM DNS validation needs the sub-zone reachable via public DNS, which requires NS delegation in the parent zone."
    }

    precondition {
      condition     = var.create_certificates || length(var.certificate_arns) > 0
      error_message = "The HTTPS listener needs a certificate: set create_certificates to true or pass certificate_arns."
    }

    precondition {
      condition     = var.webapp_alias_target == null || var.host_template == "{service}.{tenant}"
      error_message = "webapp_alias_target requires host_template = \"{service}.{tenant}\" so the tenant apex <tenant>.<domain> is a well-defined record name."
    }
  }
}

# One ingress per service, in the service's namespace, with one host rule per tenant.
# The ALB forwards Host unchanged, so the backend can resolve the tenant from it.
# Off by default: most consumers already render service ingresses in their Helm chart, joined to this ALB via
# alb.ingress.kubernetes.io/group.name = var.name.
resource "kubernetes_ingress_v1" "service" {
  for_each   = var.create_service_ingresses ? var.services : {}
  depends_on = [kubernetes_ingress_v1.alb]

  metadata {
    name      = "${var.name}-${each.key}"
    namespace = each.value.namespace

    annotations = merge(local.common_annotations, {
      "alb.ingress.kubernetes.io/healthcheck-path" = coalesce(each.value.health_check_path, var.health_check_path)
    })
  }

  spec {
    ingress_class_name = "alb"

    dynamic "rule" {
      for_each = sort([for route in values(local.routes) : route.host if route.service == each.key])

      content {
        host = rule.value
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = each.value.name
                port {
                  number = each.value.port
                }
              }
            }
          }
        }
      }
    }
  }
}

data "aws_lb_hosted_zone_id" "this" {}

resource "aws_route53_record" "this" {
  for_each = var.create_dns_records ? local.routes : {}

  zone_id = var.create_hosted_zone ? aws_route53_zone.tenant[each.value.tenant].zone_id : var.zone_id
  name    = each.value.host
  type    = "A"

  alias {
    name                   = kubernetes_ingress_v1.alb.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_lb_hosted_zone_id.this.id
    evaluate_target_health = true
  }
}

# Tenant apex A alias (e.g. acme.example.com) → external target such as a CloudFront distribution.
resource "aws_route53_record" "webapp" {
  for_each = var.webapp_alias_target == null ? toset([]) : toset(var.tenants)

  zone_id = var.create_hosted_zone ? aws_route53_zone.tenant[each.key].zone_id : var.zone_id
  name    = "${each.key}.${var.domain}"
  type    = "A"

  alias {
    name                   = var.webapp_alias_target.name
    zone_id                = var.webapp_alias_target.zone_id
    evaluate_target_health = false
  }
}
