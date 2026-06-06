# -----------------------------------------------------------------------------
# Keycloak Operator Installation
# Supports two methods:
# 1. OLM (Recommended) - Uses Operator Lifecycle Manager for automated lifecycle
# 2. Manifest - Direct CRD and deployment installation
# -----------------------------------------------------------------------------

# Operator namespace (used by both methods)
resource "kubernetes_namespace_v1" "operator" {
  count = var.install_operator && var.create_operator_namespace ? 1 : 0

  metadata {
    name = var.operator_namespace
    labels = merge(local.common_labels, {
      "app.kubernetes.io/component" = "operator"
    })
  }
}

# =============================================================================
# OLM Installation Method (Recommended for 2026+)
# =============================================================================

# OperatorGroup - Required for OLM to manage operators in a namespace
resource "kubernetes_manifest" "operator_group" {
  count = var.install_operator && var.operator_install_method == "olm" ? 1 : 0

  manifest = {
    apiVersion = "operators.coreos.com/v1"
    kind       = "OperatorGroup"
    metadata = {
      name      = "keycloak-operator-group"
      namespace = var.operator_namespace
      labels    = local.common_labels
    }
    spec = {
      # Empty targetNamespaces means operator watches all namespaces
      # Or specify namespaces to watch: targetNamespaces = [var.namespace]
      targetNamespaces = []
    }
  }

  depends_on = [kubernetes_namespace_v1.operator]
}

# OLM Subscription - Subscribes to the Keycloak Operator from OperatorHub
resource "kubernetes_manifest" "operator_subscription" {
  count = var.install_operator && var.operator_install_method == "olm" ? 1 : 0

  manifest = {
    apiVersion = "operators.coreos.com/v1alpha1"
    kind       = "Subscription"
    metadata = {
      name      = "keycloak-operator"
      namespace = var.operator_namespace
      labels    = local.common_labels
    }
    spec = merge(
      {
        channel             = var.olm_channel
        name                = "keycloak-operator"
        source              = var.olm_catalog_source
        sourceNamespace     = var.olm_catalog_source_namespace
        installPlanApproval = var.olm_install_plan_approval
      },
      # Optionally pin to a specific version
      var.olm_starting_csv != "" ? {
        startingCSV = var.olm_starting_csv
      } : {}
    )
  }

  depends_on = [
    kubernetes_namespace_v1.operator,
    kubernetes_manifest.operator_group
  ]
}

# =============================================================================
# Manifest Installation Method (Fallback for clusters without OLM)
# =============================================================================

# Keycloak CRD (manifest method only)
resource "kubernetes_manifest" "keycloak_crd" {
  count = var.install_operator && var.operator_install_method == "manifest" ? 1 : 0

  manifest = yamldecode(file("${path.module}/crds/keycloaks.k8s.keycloak.org-v1.yml"))

  field_manager {
    force_conflicts = true
  }
}

# KeycloakRealmImport CRD (manifest method only)
resource "kubernetes_manifest" "realm_import_crd" {
  count = var.install_operator && var.operator_install_method == "manifest" ? 1 : 0

  manifest = yamldecode(file("${path.module}/crds/keycloakrealmimports.k8s.keycloak.org-v1.yml"))

  field_manager {
    force_conflicts = true
  }
}

# Parse operator deployment YAML (contains multiple documents)
locals {
  use_manifest_method = var.install_operator && var.operator_install_method == "manifest"

  operator_manifests_raw = local.use_manifest_method ? split("---", file("${path.module}/crds/kubernetes.yml")) : []

  operator_manifests = {
    for idx, doc in local.operator_manifests_raw :
    idx => yamldecode(doc)
    if trimspace(doc) != "" && can(yamldecode(doc))
  }

  # Filter and update manifests to use correct namespace
  operator_manifests_namespaced = {
    for key, manifest in local.operator_manifests :
    key => merge(
      manifest,
      contains(["Deployment", "ServiceAccount", "RoleBinding", "ClusterRoleBinding"], lookup(manifest, "kind", "")) ? {
        metadata = merge(
          lookup(manifest, "metadata", {}),
          manifest.kind != "ClusterRoleBinding" ? {
            namespace = var.operator_namespace
          } : {}
        )
      } : {}
    )
  }
}

# Operator deployment manifests (manifest method only)
resource "kubernetes_manifest" "operator" {
  for_each = local.use_manifest_method ? local.operator_manifests_namespaced : {}

  manifest = each.value

  field_manager {
    force_conflicts = true
  }

  depends_on = [
    kubernetes_manifest.keycloak_crd,
    kubernetes_manifest.realm_import_crd,
    kubernetes_namespace_v1.operator
  ]
}
