# -----------------------------------------------------------------------------
# KeycloakRealmImport Custom Resources
# Used to import realm configurations on Keycloak startup
# -----------------------------------------------------------------------------

resource "kubernetes_manifest" "realm_import" {
  for_each = var.realm_imports

  manifest = {
    apiVersion = "k8s.keycloak.org/v2alpha1"
    kind       = "KeycloakRealmImport"
    metadata = {
      name      = "${var.name}-${each.key}"
      namespace = var.namespace
      labels = merge(local.common_labels, {
        "app.kubernetes.io/component" = "realm-import"
        "keycloak.org/realm"          = each.key
      })
    }
    spec = {
      keycloakCRName = kubernetes_manifest.keycloak.manifest.metadata.name
      realm          = each.value
    }
  }

  depends_on = [
    kubernetes_manifest.keycloak,
    kubernetes_manifest.realm_import_crd
  ]
}
