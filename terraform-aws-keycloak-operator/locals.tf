locals {
  # Common labels for all resources
  common_labels = merge(
    {
      "app.kubernetes.io/name"       = "keycloak"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    },
    var.labels
  )

  # Keycloak service name follows operator naming convention
  keycloak_service_name = "${var.name}-service"

  # Ingress annotations for AWS ALB
  ingress_annotations = merge(
    {
      "kubernetes.io/ingress.class"                            = var.ingress_class_name
      "alb.ingress.kubernetes.io/group.name"                   = var.ingress_group_name
      "alb.ingress.kubernetes.io/scheme"                       = var.ingress_scheme
      "alb.ingress.kubernetes.io/target-type"                  = var.ingress_target_type
      "alb.ingress.kubernetes.io/listen-ports"                 = jsonencode([{ "HTTP" = 80 }, { "HTTPS" = 443 }])
      "alb.ingress.kubernetes.io/ssl-redirect"                 = var.ingress_ssl_redirect ? "443" : ""
      "alb.ingress.kubernetes.io/healthcheck-path"             = var.ingress_healthcheck_path
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = tostring(var.ingress_healthcheck_interval)
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = tostring(var.ingress_healthcheck_timeout)
      "alb.ingress.kubernetes.io/healthy-threshold-count"      = tostring(var.ingress_healthcheck_healthy_threshold)
      "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = tostring(var.ingress_healthcheck_unhealthy_threshold)
    },
    var.ingress_certificate_arn != null ? {
      "alb.ingress.kubernetes.io/certificate-arn" = var.ingress_certificate_arn
    } : {},
    var.ingress_additional_annotations
  )

  # Build additional options list for Keycloak CR
  additional_options_list = [
    for key, value in var.additional_options : {
      name  = key
      value = value
    }
  ]

  # HTTP configuration for Keycloak CR
  http_config = var.tls_secret_name != null ? {
    tlsSecret   = var.tls_secret_name
    httpEnabled = var.http_enabled
    } : {
    httpEnabled = var.http_enabled
  }

  # Hostname configuration for Keycloak CR
  hostname_config = merge(
    {
      hostname = var.hostname
      strict   = var.hostname_strict
    },
    var.hostname_admin != null ? {
      admin = var.hostname_admin
    } : {},
    var.hostname_strict_backchannel ? {
      strictBackchannel = var.hostname_strict_backchannel
    } : {}
  )
}
