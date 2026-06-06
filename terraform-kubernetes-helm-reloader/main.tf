resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
    labels = merge(
      {
        "app.kubernetes.io/name"       = "reloader"
        "app.kubernetes.io/instance"   = var.release_name
        "app.kubernetes.io/managed-by" = "terraform"
      },
      var.namespace_labels
    )
    annotations = var.namespace_annotations
  }
}

resource "helm_release" "this" {
  name             = var.release_name
  namespace        = var.namespace
  repository       = var.chart_url
  chart            = "reloader"
  version          = var.chart_version
  max_history      = 3
  create_namespace = false # We handle namespace creation separately
  values           = [local.manifest]

  depends_on = [kubernetes_namespace.this]
}
