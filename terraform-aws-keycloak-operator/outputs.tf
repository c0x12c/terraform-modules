# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "keycloak_name" {
  description = "Name of the Keycloak custom resource"
  value       = kubernetes_manifest.keycloak.manifest.metadata.name
}

output "keycloak_namespace" {
  description = "Namespace where Keycloak is deployed"
  value       = var.namespace
}

output "keycloak_hostname" {
  description = "Primary hostname for Keycloak"
  value       = var.hostname
}

output "keycloak_admin_hostname" {
  description = "Admin console hostname (if different from primary)"
  value       = var.hostname_admin
}

output "admin_credentials_secret" {
  description = "Kubernetes secret name containing initial admin credentials"
  value       = "${var.name}-initial-admin"
}

output "keycloak_service_name" {
  description = "Name of the Keycloak service"
  value       = local.keycloak_service_name
}

output "ingress_name" {
  description = "Name of the ingress resource (if created)"
  value       = var.create_ingress ? kubernetes_ingress_v1.keycloak[0].metadata[0].name : null
}

output "operator_namespace" {
  description = "Namespace where the Keycloak Operator is deployed"
  value       = var.install_operator ? var.operator_namespace : null
}

output "operator_install_method" {
  description = "Method used to install the operator (olm or manifest)"
  value       = var.install_operator ? var.operator_install_method : null
}

output "keycloak_instances" {
  description = "Number of Keycloak replicas"
  value       = var.keycloak_instances
}

output "realm_imports" {
  description = "Map of realm import resource names"
  value = {
    for key, _ in var.realm_imports :
    key => "${var.name}-${key}"
  }
}
