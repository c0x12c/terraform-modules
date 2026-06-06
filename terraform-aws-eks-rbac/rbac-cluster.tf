resource "kubernetes_cluster_role" "this" {
  count = local.cluster_roles_count
  metadata {
    name = "${var.cluster_roles[count.index].name}-clusterrole"
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = true
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
  }
  dynamic "rule" {
    for_each = local.cluster_privileges[var.cluster_roles[count.index].privilege].rules
    content {
      api_groups        = contains(keys(rule.value), "api_groups") ? rule.value["api_groups"] : null
      resources         = contains(keys(rule.value), "resources") ? rule.value["resources"] : null
      verbs             = contains(keys(rule.value), "verbs") ? rule.value["verbs"] : null
      non_resource_urls = contains(keys(rule.value), "non_resource_urls") ? rule.value["non_resource_urls"] : null
    }
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  count = local.cluster_roles_count
  metadata {
    name = "${var.cluster_roles[count.index].name}-clusterrole-binding"
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = true
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${var.cluster_roles[count.index].name}-clusterrole"
  }
  subject {
    kind      = "Group"
    name      = "custom:${var.cluster_roles[count.index].name}-group"
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [kubernetes_cluster_role.this]
}
