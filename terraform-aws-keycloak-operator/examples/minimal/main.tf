# -----------------------------------------------------------------------------
# Minimal Example: Keycloak with Operator
#
# This is the simplest possible deployment using:
# - OLM for operator installation (assumes OLM is already installed)
# - External PostgreSQL database
# - AWS ALB Ingress
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.9.8"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "db_host" {
  description = "PostgreSQL host"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "hostname" {
  description = "Keycloak hostname"
  type        = string
}

# -----------------------------------------------------------------------------
# Database Secret
# -----------------------------------------------------------------------------

resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "keycloak-db-credentials"
    namespace = "keycloak"
  }

  data = {
    username = "keycloak"
    password = var.db_password
  }
}

# -----------------------------------------------------------------------------
# Keycloak Module
# -----------------------------------------------------------------------------

module "keycloak" {
  source = "../.."

  name      = "keycloak"
  namespace = "keycloak"
  hostname  = var.hostname

  # Operator (OLM)
  install_operator        = true
  operator_install_method = "olm"

  # Database
  db_host = var.db_host
  db_username_secret = {
    name = kubernetes_secret.db_credentials.metadata[0].name
    key  = "username"
  }
  db_password_secret = {
    name = kubernetes_secret.db_credentials.metadata[0].name
    key  = "password"
  }

  # Ingress
  create_ingress = true

  depends_on = [kubernetes_secret.db_credentials]
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "admin_secret" {
  description = "Secret name containing initial admin credentials"
  value       = module.keycloak.admin_credentials_secret
}

output "hostname" {
  value = module.keycloak.keycloak_hostname
}
