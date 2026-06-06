locals {
  manifest = <<-YAML
podIdentity:
  aws:
    irsa:
      enabled: ${var.enabled_aws_irsa}
      roleArn: ${local.keda_role_arn}
resources:
  operator:
    limits:
      cpu: ${var.operator_cpu}
      memory: ${var.operator_memory}
    requests:
      cpu: ${var.operator_cpu}
      memory: ${var.operator_memory}
  metricServer:
    limits:
      cpu: ${var.metric_server_cpu}
      memory: ${var.metric_server_memory}
    requests:
      cpu: ${var.metric_server_cpu}
      memory: ${var.metric_server_memory}
  webhooks:
    limits:
      cpu: ${var.admission_webhook_server_cpu}
      memory: ${var.admission_webhook_server_memory}
    requests:
      cpu: ${var.admission_webhook_server_cpu}
      memory: ${var.admission_webhook_server_memory}
YAML
}

resource "helm_release" "keda" {
  name             = var.helm_release_name
  chart            = "keda"
  repository       = "https://kedacore.github.io/charts"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  values = [local.manifest]

  set = flatten([
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

  lifecycle {
    ignore_changes = [
      timeout
    ]
  }
}
