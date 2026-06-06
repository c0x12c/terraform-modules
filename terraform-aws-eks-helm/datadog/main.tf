locals {
  manifest = <<YAML
datadog:
  logs:
    enabled: ${var.enabled_logs}
    containerCollectAll: ${var.enabled_container_collect_all_logs}
agents:
  enabled: ${var.enabled_agent}
clusterAgent:
  enabled: ${var.enabled_cluster_agent}
  metricsProvider:
    enabled: ${var.enabled_metric_provider}
  env:
%{~for env in var.datadog_envs}
    - name: ${env.name}
      value: ${yamlencode(env.value)}
%{~endfor~}
  confd:
    http_check.yaml: |-
      cluster_check: ${var.enabled_cluster_check}
      init_config:
      instances:
%{for url in var.http_check_urls}
        - name: ${url}
          url: ${url}
          tags:
            - env: ${var.environment}
%{endfor}
YAML
}

resource "random_password" "cluster_agent_token" {
  length  = 32
  special = false
}

resource "helm_release" "this" {
  name             = var.helm_release_name
  namespace        = var.namespace
  repository       = "https://helm.datadoghq.com"
  chart            = "datadog"
  version          = var.chart_version
  create_namespace = true
  timeout          = var.timeout

  set_sensitive {
    name  = "datadog.apiKey"
    value = var.datadog_api_key
  }
  set_sensitive {
    name  = "datadog.appKey"
    value = var.datadog_app_key
  }
  set_sensitive {
    name  = "datadog.site"
    value = var.datadog_site
  }
  set_sensitive {
    name  = "datadog.clusterName"
    value = var.cluster_name
  }
  set_sensitive {
    name  = "clusterAgent.token"
    value = random_password.cluster_agent_token.result
  }

  dynamic "set" {
    for_each = var.node_selector
    content {
      name  = "agent.nodeSelector.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.node_selector
    content {
      name  = "clusterAgent.nodeSelector.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "agent.tolerations[${set.key}].key"
      value = lookup(set.value, "key", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "agent.tolerations[${set.key}].operator"
      value = lookup(set.value, "operator", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "agent.tolerations[${set.key}].value"
      value = lookup(set.value, "value", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "agent.tolerations[${set.key}].effect"
      value = lookup(set.value, "effect", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "clusterAgent.tolerations[${set.key}].key"
      value = lookup(set.value, "key", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "clusterAgent.tolerations[${set.key}].operator"
      value = lookup(set.value, "operator", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "clusterAgent.tolerations[${set.key}].value"
      value = lookup(set.value, "value", "")
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "clusterAgent.tolerations[${set.key}].effect"
      value = lookup(set.value, "effect", "")
    }
  }

  values = [local.manifest]
  lifecycle {
    ignore_changes = [
      timeout
    ]
  }
}
