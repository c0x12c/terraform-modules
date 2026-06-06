# Annotations for argocd-application-controller ServiceAccount
resource "kubernetes_annotations" "argocd_application_controller" {
  count = var.enabled_aws_management_role ? 1 : 0

  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = "argocd-application-controller"
    namespace = var.argocd_namespace
  }
  annotations = {
    "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.aws_management_role.role_name}"
  }
  depends_on = [helm_release.this, aws_iam_role.this]
}

# Annotations for argocd-applicationset-controller ServiceAccount
resource "kubernetes_annotations" "argocd_applicationset_controller" {
  count = var.enabled_aws_management_role ? 1 : 0

  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = "argocd-applicationset-controller"
    namespace = var.argocd_namespace
  }
  annotations = {
    "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.aws_management_role.role_name}"
  }
  depends_on = [helm_release.this, aws_iam_role.this]

}

# Annotations for argocd-server ServiceAccount
resource "kubernetes_annotations" "argocd_server" {
  count = var.enabled_aws_management_role ? 1 : 0

  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = "argocd-server"
    namespace = var.argocd_namespace
  }
  annotations = {
    "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.aws_management_role.role_name}"
  }
  depends_on = [helm_release.this, aws_iam_role.this]

}