# -----------------------------------------------------------------------------
# Complete Example: Keycloak with Operator (OLM Installation)
#
# This example demonstrates a production-ready Keycloak deployment using:
# - OLM (Operator Lifecycle Manager) for operator installation (recommended)
# - External RDS PostgreSQL database
# - AWS ALB Ingress
# - Realm import for initial configuration
# -----------------------------------------------------------------------------

# Prerequisite: OLM must be installed on your cluster
# For vanilla Kubernetes: https://olm.operatorframework.io/docs/getting-started/
# For OpenShift: OLM is pre-installed

terraform {
  required_version = ">= 1.9.8"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "keycloak_hostname" {
  description = "Keycloak hostname"
  type        = string
  default     = "keycloak.example.com"
}

variable "db_password" {
  description = "Database password (should come from secrets manager in production)"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "RDS PostgreSQL endpoint"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Keycloak Namespace and Secrets
# -----------------------------------------------------------------------------

resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = "keycloak"
    labels = {
      "app.kubernetes.io/name"       = "keycloak"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# Database credentials secret
resource "kubernetes_secret" "keycloak_db" {
  metadata {
    name      = "keycloak-db-credentials"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }

  data = {
    username = "keycloak"
    password = var.db_password
  }

  type = "Opaque"
}

# -----------------------------------------------------------------------------
# Keycloak Operator Module
# -----------------------------------------------------------------------------

module "keycloak" {
  source = "../.."

  name             = "keycloak"
  namespace        = kubernetes_namespace.keycloak.metadata[0].name
  create_namespace = false

  # Operator Installation (OLM - Recommended)
  install_operator          = true
  operator_install_method   = "olm"
  operator_namespace        = "keycloak-operator"
  olm_channel               = "fast"
  olm_install_plan_approval = "Automatic"

  # Keycloak Configuration
  hostname           = var.keycloak_hostname
  keycloak_instances = 2
  keycloak_image     = "quay.io/keycloak/keycloak:26.0.7"

  # Database (External RDS PostgreSQL)
  db_host = var.db_host
  db_port = 5432
  db_name = "keycloak"
  db_username_secret = {
    name = kubernetes_secret.keycloak_db.metadata[0].name
    key  = "username"
  }
  db_password_secret = {
    name = kubernetes_secret.keycloak_db.metadata[0].name
    key  = "password"
  }

  # Database connection pool
  db_pool_initial_size = 5
  db_pool_min_size     = 5
  db_pool_max_size     = 20

  # HTTP/TLS
  http_enabled = true

  # Proxy (behind ALB)
  proxy_headers = "xforwarded"

  # AWS ALB Ingress
  create_ingress          = true
  ingress_class_name      = "alb"
  ingress_group_name      = "external"
  ingress_scheme          = "internet-facing"
  ingress_target_type     = "ip"
  ingress_ssl_redirect    = true
  ingress_certificate_arn = var.acm_certificate_arn

  # Resources
  resources = {
    requests = {
      cpu    = "500m"
      memory = "1Gi"
    }
    limits = {
      cpu    = "2"
      memory = "2Gi"
    }
  }

  # Realm Import (Optional - for initial setup)
  realm_imports = {
    "production" = {
      realm       = "production"
      enabled     = true
      displayName = "Production Realm"

      # Default client for the realm
      clients = [
        {
          clientId                  = "web-app"
          enabled                   = true
          publicClient              = true
          standardFlowEnabled       = true
          directAccessGrantsEnabled = false
          redirectUris = [
            "https://app.example.com/*",
            "https://app.example.com/callback"
          ]
          webOrigins = [
            "https://app.example.com"
          ]
        }
      ]
    }
  }

  # Labels
  labels = {
    "environment" = "production"
    "team"        = "platform"
  }

  depends_on = [
    kubernetes_namespace.keycloak,
    kubernetes_secret.keycloak_db
  ]
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "keycloak_hostname" {
  description = "Keycloak hostname"
  value       = module.keycloak.keycloak_hostname
}

output "keycloak_admin_secret" {
  description = "Secret containing initial admin credentials"
  value       = module.keycloak.admin_credentials_secret
}

output "keycloak_namespace" {
  description = "Keycloak namespace"
  value       = module.keycloak.keycloak_namespace
}

output "operator_namespace" {
  description = "Operator namespace"
  value       = module.keycloak.operator_namespace
}

output "operator_install_method" {
  description = "Operator installation method"
  value       = module.keycloak.operator_install_method
}
