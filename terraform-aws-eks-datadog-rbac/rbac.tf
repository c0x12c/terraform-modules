locals {
  default_service_account = var.enable_default_service_accounts ? {
    default     = distinct(concat(["default"], [var.default_service_account]))
    kube-system = ["kube-system"]
  } : {}

  service_accounts = merge(
    local.default_service_account,
    var.custom_service_accounts,
  )
}

resource "kubernetes_cluster_role" "datadog_agent" {
  count = var.create_datadog_agent_cluster_role ? 1 : 0

  metadata {
    name = var.datadog_agent_cluster_role_name
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "namespaces", "endpoints"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes/metrics", "nodes/spec", "nodes/stats", "nodes/proxy", "nodes/pods", "nodes/healthz"]
    verbs      = ["get"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "datadog_agent" {
  for_each = local.service_accounts

  metadata {
    name = "${var.datadog_agent_cluster_role_name}-${each.key}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.datadog_agent_cluster_role_name
  }

  dynamic "subject" {
    for_each = each.value
    content {
      kind      = "ServiceAccount"
      name      = subject.value
      namespace = each.key
    }
  }

  depends_on = [kubernetes_cluster_role.datadog_agent[0]]
}
