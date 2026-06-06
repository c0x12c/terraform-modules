# -----------------------------------------------------------------------------
# Keycloak Namespace
# -----------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "keycloak" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name   = var.namespace
    labels = local.common_labels
  }
}

# -----------------------------------------------------------------------------
# Keycloak Custom Resource
# -----------------------------------------------------------------------------

resource "kubernetes_manifest" "keycloak" {
  manifest = {
    apiVersion = "k8s.keycloak.org/v2alpha1"
    kind       = "Keycloak"
    metadata = {
      name      = var.name
      namespace = var.namespace
      labels    = local.common_labels
    }
    spec = merge(
      {
        instances = var.keycloak_instances
        image     = var.keycloak_image

        # Database configuration (external PostgreSQL)
        db = {
          vendor          = "postgres"
          host            = var.db_host
          port            = var.db_port
          database        = var.db_name
          schema          = var.db_schema
          usernameSecret  = var.db_username_secret
          passwordSecret  = var.db_password_secret
          poolInitialSize = var.db_pool_initial_size
          poolMinSize     = var.db_pool_min_size
          poolMaxSize     = var.db_pool_max_size
        }

        # HTTP configuration
        http = local.http_config

        # Hostname configuration
        hostname = local.hostname_config

        # Proxy configuration
        proxy = {
          headers = var.proxy_headers
        }

        # Resource limits
        resources = var.resources

        # Transaction settings
        transaction = {
          xaEnabled = var.transaction_xa_enabled
        }
      },

      # Image pull secrets (if specified)
      length(var.keycloak_image_pull_secrets) > 0 ? {
        imagePullSecrets = [
          for secret in var.keycloak_image_pull_secrets : { name = secret }
        ]
      } : {},

      # Features configuration (if specified)
      length(var.features_enabled) > 0 || length(var.features_disabled) > 0 ? {
        features = merge(
          length(var.features_enabled) > 0 ? { enabled = var.features_enabled } : {},
          length(var.features_disabled) > 0 ? { disabled = var.features_disabled } : {}
        )
      } : {},

      # Additional options (if specified)
      length(local.additional_options_list) > 0 ? {
        additionalOptions = local.additional_options_list
      } : {},

      # Unsupported pod template (for advanced customization)
      var.unsupported_pod_template != null ? {
        unsupported = {
          podTemplate = var.unsupported_pod_template
        }
      } : {}
    )
  }

  # Dependencies vary based on operator installation method
  depends_on = [
    kubernetes_namespace_v1.keycloak,
    # OLM method: wait for subscription
    kubernetes_manifest.operator_subscription,
    # Manifest method: wait for CRDs and operator deployment
    kubernetes_manifest.keycloak_crd,
    kubernetes_manifest.operator
  ]
}

# -----------------------------------------------------------------------------
# AWS ALB Ingress
# -----------------------------------------------------------------------------

resource "kubernetes_ingress_v1" "keycloak" {
  count = var.create_ingress ? 1 : 0

  metadata {
    name        = "${var.name}-ingress"
    namespace   = var.namespace
    labels      = local.common_labels
    annotations = local.ingress_annotations
  }

  spec {
    ingress_class_name = var.ingress_class_name

    rule {
      host = var.hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = local.keycloak_service_name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }

    # Add admin hostname rule if specified
    dynamic "rule" {
      for_each = var.hostname_admin != null ? [1] : []

      content {
        host = var.hostname_admin

        http {
          path {
            path      = "/"
            path_type = "Prefix"

            backend {
              service {
                name = local.keycloak_service_name
                port {
                  number = 8080
                }
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.keycloak]
}
