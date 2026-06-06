resource "kubernetes_role" "this" {
  count = local.namespace_role_count
  metadata {
    name      = "${var.namespace_roles[count.index].namespace}-${var.namespace_roles[count.index].privilege}-role"
    namespace = var.namespace_roles[count.index].namespace
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = true
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
  }

  dynamic "rule" {
    for_each = local.namespace_privileges[var.namespace_roles[count.index].privilege].rules
    content {
      api_groups = rule.value["api_groups"]
      resources  = rule.value["resources"]
      verbs      = rule.value["verbs"]
    }
  }
}

resource "kubernetes_role_binding" "this" {
  count = local.namespace_role_count
  metadata {
    name      = "${var.namespace_roles[count.index].namespace}-${var.namespace_roles[count.index].privilege}-role-binding"
    namespace = var.namespace_roles[count.index].namespace
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = true
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${var.namespace_roles[count.index].namespace}-${var.namespace_roles[count.index].privilege}-role"
  }
  subject {
    kind      = "Group"
    name      = "custom:${var.namespace_roles[count.index].namespace}-${var.namespace_roles[count.index].privilege}-group"
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [kubernetes_role.this]
}
