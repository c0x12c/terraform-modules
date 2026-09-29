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

module "acm" {
  source   = "../terraform-aws-acm"
  for_each = var.create_certificates ? local.certificate_domains : toset([])

  zone_id     = var.zone_id
  domain_name = each.key
  tags        = var.tags

  # The HTTPS listener rejects a certificate that is not issued yet.
  wait_for_validation = true
}

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
      condition     = var.zone_id != null || (!var.create_certificates && !var.create_dns_records)
      error_message = "Set zone_id, or set create_certificates and create_dns_records to false."
    }

    precondition {
      condition     = var.create_certificates || length(var.certificate_arns) > 0
      error_message = "The HTTPS listener needs a certificate: set create_certificates to true or pass certificate_arns."
    }
  }
}

# One ingress per service, in the service's namespace, with one host rule per tenant.
# The ALB forwards Host unchanged, so the backend can resolve the tenant from it.
resource "kubernetes_ingress_v1" "service" {
  for_each   = var.services
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

  zone_id = var.zone_id
  name    = each.value.host
  type    = "A"

  alias {
    name                   = kubernetes_ingress_v1.alb.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_lb_hosted_zone_id.this.id
    evaluate_target_health = true
  }
}
