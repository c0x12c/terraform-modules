##### Metrics Server  ###############################
resource "helm_release" "metrics_server" {
  name       = var.helm_release_name
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.helm_chart_version
  namespace  = var.namespace
  keyring    = ""

  # If true, allow unauthenticated access to /metrics.
  set = flatten([
    [{
      name  = "metrics.enabled"
      value = false
    }],
    [for key, value in var.node_selector : {
      name  = "nodeSelector.${key}"
      value = value
    }],
    [for key, value in var.tolerations : {
      name  = "tolerations[${key}].key"
      value = lookup(value, "key", "")
    }],
    [for key, value in var.tolerations : {
      name  = "tolerations[${key}].operator"
      value = lookup(value, "operator", "")
    }],
    [for key, value in var.tolerations : {
      name  = "tolerations[${key}].value"
      value = lookup(value, "value", "")
    }],
    [for key, value in var.tolerations : {
      name  = "tolerations[${key}].effect"
      value = lookup(value, "effect", "")
    }],
  ])
}
