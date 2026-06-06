##### Metrics Server  ###############################
resource "helm_release" "metrics_server" {
  name       = var.helm_release_name
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.helm_chart_version
  namespace  = var.namespace
  keyring    = ""

  # If true, allow unauthenticated access to /metrics.
  set {
    name  = "metrics.enabled"
    value = false
  }

  dynamic "set" {
    for_each = var.node_selector
    content {
      name  = "nodeSelector.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "tolerations[${set.key}].key"
      value = lookup(set.value, "key", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "tolerations[${set.key}].operator"
      value = lookup(set.value, "operator", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "tolerations[${set.key}].value"
      value = lookup(set.value, "value", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "tolerations[${set.key}].effect"
      value = lookup(set.value, "effect", "")
    }
  }
}
