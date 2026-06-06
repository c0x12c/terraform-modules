locals {
  ssl_redirect_action    = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
  listen_port_http_https = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
}

resource "kubernetes_ingress_v1" "external_alb" {
  depends_on = [
    time_sleep.wait_for_aws_load_balancer_webhook_is_running
  ]

  wait_for_load_balancer = true

  metadata {
    name      = "external-alb"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                        = "alb"
      "alb.ingress.kubernetes.io/group.name"               = var.external_group_name
      "alb.ingress.kubernetes.io/certificate-arn"          = join(",", var.certificate_arn)
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=${var.idle_timeout}"
      "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
      "alb.ingress.kubernetes.io/subnets"                  = join(",", var.public_subnet)
      "alb.ingress.kubernetes.io/ssl-policy"               = var.ssl_policy
      "alb.ingress.kubernetes.io/target-type"              = "ip"
      "alb.ingress.kubernetes.io/listen-ports"             = local.listen_port_http_https
      "alb.ingress.kubernetes.io/actions.ssl-redirect"     = local.ssl_redirect_action
      "alb.ingress.kubernetes.io/wafv2-acl-arn"            = var.wafv2_arn
    }
  }
  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            dynamic "service" {
              for_each = var.external_default_service != null ? [var.external_default_service] : []
              content {
                name = lookup(service.value, "name", null)
                port {
                  number = lookup(service.value, "port", null)
                }
              }
            }
            dynamic "service" {
              for_each = var.external_default_service == null ? ["ssl-redirect"] : []
              content {
                name = "ssl-redirect"
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
}

resource "kubernetes_ingress_v1" "internal_alb" {
  count = var.enable_internal_alb ? 1 : 0

  depends_on = [
    time_sleep.wait_for_aws_load_balancer_webhook_is_running
  ]

  wait_for_load_balancer = true

  metadata {
    name      = "internal-alb"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                        = "alb"
      "alb.ingress.kubernetes.io/group.name"               = var.internal_group_name
      "alb.ingress.kubernetes.io/certificate-arn"          = join(",", var.certificate_arn)
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=${var.idle_timeout}"
      "alb.ingress.kubernetes.io/scheme"                   = "internal"
      "alb.ingress.kubernetes.io/subnets"                  = join(",", var.private_subnet)
      "alb.ingress.kubernetes.io/ssl-policy"               = var.ssl_policy
      "alb.ingress.kubernetes.io/target-type"              = "ip"
      "alb.ingress.kubernetes.io/listen-ports"             = local.listen_port_http_https
      "alb.ingress.kubernetes.io/actions.ssl-redirect"     = local.ssl_redirect_action
    }
  }
  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            dynamic "service" {
              for_each = var.internal_default_service != null ? [var.internal_default_service] : []
              content {
                name = lookup(service.value, "name", null)
                port {
                  number = lookup(service.value, "port", null)
                }
              }
            }
            dynamic "service" {
              for_each = var.internal_default_service == null ? ["ssl-redirect"] : []
              content {
                name = "ssl-redirect"
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
}
