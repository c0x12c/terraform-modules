resource "kubernetes_cluster_role_v1" "service_bot" {
  metadata {
    name = var.service_name
  }

  dynamic "rule" {
    for_each = [
      {
        api_groups = ["", "apps", "extensions"]
        resources  = ["deployments", "replicasets", "pods", "services"]
        verbs      = ["get", "list", "update", "patch"]
      },
      {
        api_groups = ["batch"]
        resources  = ["jobs", "cronjobs"]
        verbs      = ["get", "list", "update", "patch"]
      },
      {
        api_groups = [""]
        resources  = ["configmaps", "secrets", "serviceaccounts"]
        verbs      = ["get", "list", "create", "update", "patch"]
      },
      {
        api_groups = ["autoscaling"]
        resources  = ["horizontalpodautoscalers"]
        verbs      = ["get", "list", "update", "patch"]
      },
      {
        api_groups = ["networking.k8s.io"]
        resources  = ["ingresses"]
        verbs      = ["get", "list", "update", "patch"]
      }
    ]

    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_cluster_role_binding_v1" "service_bot" {
  metadata {
    name = var.service_name
  }

  role_ref {
    kind      = "ClusterRole"
    api_group = "rbac.authorization.k8s.io"
    name      = kubernetes_cluster_role_v1.service_bot.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.service_name
    namespace = var.namespace
  }
}
