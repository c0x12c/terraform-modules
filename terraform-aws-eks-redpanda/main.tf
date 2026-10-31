resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

resource "helm_release" "operator" {
  count = var.operator.install ? 1 : 0

  name       = "${var.name}-operator"
  chart      = "operator"
  repository = "https://charts.redpanda.com"
  version    = var.operator.chart_version
  namespace  = var.namespace

  # Same placement as the brokers: on a Fargate-first cluster the broker pool can be the only EC2
  # capacity the operator's namespace reaches, and the chart sets no tolerations of its own.
  values = [yamlencode(merge({
    crds               = { enabled = true }
    additionalCmdFlags = ["--namespace=${var.namespace}"]
  }, local.scheduling, [{ monitoring = { enabled = true, labels = var.monitoring.labels } }, {}][var.monitoring.enabled ? 0 : 1]))]

  depends_on = [kubernetes_namespace_v1.this]
}

# The Redpanda, User and Topic custom resources ship as a local chart, so a first apply
# does not need the operator's CRDs to exist at plan time.
resource "helm_release" "cluster" {
  name      = var.name
  chart     = "${path.module}/charts/redpanda-cluster"
  namespace = var.namespace
  timeout   = 1800

  values = [yamlencode({
    clusterName    = var.name
    clusterSpec    = local.cluster_spec
    brokersAddress = local.brokers_address
    adminSecret    = local.admin_secret
    tlsEnabled     = var.tls_enabled
    image          = "docker.redpanda.com/redpandadata/redpanda:${var.redpanda_version}"
    scheduling     = local.scheduling
    tenants = {
      for k, _ in var.tenants : k => {
        secretName = local.tenant_secrets[k]
        acls       = local.tenant_acls[k]
      }
    }
    topics = local.topics
    quotas = local.quotas
  })]

  lifecycle {
    precondition {
      condition     = !var.tiered_storage.enabled || (var.oidc_provider != null && var.enterprise_license_secret != null)
      error_message = "tiered_storage needs oidc_provider (for the IRSA role) and enterprise_license_secret."
    }
    precondition {
      condition     = alltrue([for t in values(local.topics) : t.replication_factor <= local.brokers.replicas])
      error_message = "A topic's replication_factor exceeds the broker count."
    }
  }

  depends_on = [
    helm_release.operator,
    kubernetes_secret_v1.superusers,
    kubernetes_secret_v1.admin,
    kubernetes_secret_v1.bootstrap,
    kubernetes_secret_v1.tenant,
    aws_eks_node_group.this,
    aws_iam_role_policy.tiered,
  ]
}

# Its own release so a bad rule or a missing dashboard namespace cannot block broker changes.
resource "helm_release" "monitoring" {
  count = var.monitoring.enabled ? 1 : 0

  name      = "${var.name}-monitoring"
  chart     = "${path.module}/charts/redpanda-monitoring"
  namespace = var.namespace

  values = [yamlencode({
    clusterName = var.name
    replicas    = local.brokers.replicas
    monitoring = {
      labels                 = var.monitoring.labels
      dashboardNamespace     = var.monitoring.dashboard_namespace
      diskUsedPercent        = var.monitoring.disk_used_percent
      lagMessages            = var.monitoring.lag_messages
      lagExcludedGroupsRegex = var.monitoring.lag_excluded_groups_regex
      runbookUrl             = var.monitoring.runbook_url
      dashboardUrl           = var.monitoring.dashboard_url
    }
  })]

  depends_on = [helm_release.cluster]
}
