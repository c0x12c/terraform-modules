locals {
  image_tag_line = var.image_tag != "" ? "imageTag: ${var.image_tag}\n" : ""

  manifest = <<-YAML
    ${local.image_tag_line}grafana:
      enabled: ${var.enable_grafana}
      persistence:
        enabled: ${var.grafana_persistence_enabled}

    mysql:
      useExternal: ${var.mysql_use_external}
      externalServer: ${var.mysql_external_server}
      externalPort: ${var.mysql_external_port}
      username: ${var.mysql_username}
      database: ${var.mysql_database}
      replicaCount: 1
      storage:
        type: pvc
        class: "${var.mysql_storage_class}"
        size: ${var.mysql_storage_size}
      resources: ${jsonencode(var.mysql_resources)}

    lake:
      replicaCount: ${var.lake_replica_count}
      resources: ${jsonencode(var.lake_resources)}
      encryptionSecret:
        autoCreateSecret: true

    ui:
      replicaCount: ${var.ui_replica_count}
      resources: ${jsonencode(var.ui_resources)}

    ingress:
      enabled: ${var.ingress_enabled}
      className: ${var.ingress_class_name}
      hostname: ${var.hostname}
      annotations: ${jsonencode(var.ingress_annotations)}
  YAML

  sensitive_values = merge(
    var.encryption_secret != "" ? { "lake.encryptionSecret.secret" = var.encryption_secret } : {},
    var.mysql_password != "" ? { "mysql.password" = var.mysql_password } : {},
    var.mysql_root_password != "" ? { "mysql.rootPassword" = var.mysql_root_password } : {},
    var.grafana_admin_password != "" ? { "grafana.adminPassword" = var.grafana_admin_password } : {},
  )
}

resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

resource "helm_release" "devlake" {
  name             = var.release_name
  repository       = var.chart_repository
  chart            = var.chart_name
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = false
  timeout          = var.helm_release_timeout

  values = [local.manifest]

  set_sensitive = [
    for key, value in local.sensitive_values : {
      name  = key
      value = value
    }
  ]

  depends_on = [kubernetes_namespace_v1.this]

  lifecycle {
    ignore_changes = [timeout]
  }
}
