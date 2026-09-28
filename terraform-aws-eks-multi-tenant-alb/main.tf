locals {
  # "acme/auth" => { service = "auth", fqdn = "auth.acme.example.com" }
  routes = merge([
    for tenant, hosts in var.tenant_hosts : {
      for service, host in hosts : "${tenant}/${service}" => {
        service = service
        fqdn    = "${host}.${var.domain}"
      }
    }
  ]...)

  services_in_use = toset([for route in values(local.routes) : route.service])

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

# One wildcard certificate per tenant: a *.<domain> certificate does not cover a second level such as auth.acme.<domain>.
module "acm" {
  source   = "../terraform-aws-acm"
  for_each = var.tenant_hosts

  zone_id     = var.zone_id
  domain_name = "*.${each.key}.${var.domain}"
  tags        = var.tags

  # The HTTPS listener rejects a certificate that is not issued yet.
  wait_for_validation = true
}

# Creates the ALB, its HTTPS listener with every tenant certificate (SNI), and a default 404.
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
        "alb.ingress.kubernetes.io/certificate-arn"          = join(",", [for cert in module.acm : cert.acm_certificate_arn])
        "alb.ingress.kubernetes.io/ssl-policy"               = var.ssl_policy
        "alb.ingress.kubernetes.io/load-balancer-attributes" = join(",", [for key, value in local.load_balancer_attributes : "${key}=${value}"])
        "alb.ingress.kubernetes.io/actions.response-404" = jsonencode({
          type                = "fixed-response"
          fixedResponseConfig = { contentType = "text/plain", statusCode = "404", messageBody = "Not found" }
        })
      },
      length(var.security_group_ids) > 0 ? { "alb.ingress.kubernetes.io/security-groups" = join(",", var.security_group_ids) } : {},
      length(var.tags) > 0 ? { "alb.ingress.kubernetes.io/tags" = join(",", [for key, value in var.tags : "${key}=${value}"]) } : {},
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
}

# One ingress per service, in the service's namespace, with one host rule per tenant host.
# The ALB forwards Host unchanged, so the backend can resolve the tenant from it.
resource "kubernetes_ingress_v1" "service" {
  for_each   = local.services_in_use
  depends_on = [kubernetes_ingress_v1.alb]

  metadata {
    name      = "${var.name}-${each.key}"
    namespace = var.services[each.key].namespace

    annotations = merge(local.common_annotations, {
      "alb.ingress.kubernetes.io/healthcheck-path" = var.health_check_path
    })
  }

  spec {
    ingress_class_name = "alb"

    dynamic "rule" {
      for_each = sort([for route in values(local.routes) : route.fqdn if route.service == each.key])

      content {
        host = rule.value
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = var.services[each.key].name
                port {
                  number = var.services[each.key].port
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
  for_each = local.routes

  zone_id = var.zone_id
  name    = each.value.fqdn
  type    = "A"

  alias {
    name                   = kubernetes_ingress_v1.alb.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_lb_hosted_zone_id.this.id
    evaluate_target_health = true
  }
}
