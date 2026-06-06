locals {
  manifest = <<YAML
%{if var.name_override != null}
nameOverride: ${var.name_override}
%{endif}
%{if var.fullname_override != null}
fullnameOverride: ${var.fullname_override}
%{endif}
datadog:
  logs:
    enabled: ${var.enabled_logs}
    containerCollectAll: ${var.enabled_container_collect_all_logs}
  %{if var.container_exclude != null}
  containerExclude: ${var.container_exclude}
  %{endif}
  %{if var.container_include != null}
  containerInclude: ${var.container_include}
  %{endif}
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
      instances: %{for url in var.http_check_urls}
        - name: ${url}
          url: ${url}
          tags:
            - env:${var.environment}
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

  set_sensitive = [
    {
      name  = "datadog.apiKey"
      value = var.datadog_api_key
    },
    {
      name  = "datadog.appKey"
      value = var.datadog_app_key
    },
    {
      name  = "datadog.site"
      value = var.datadog_site
    },
    {
      name  = "datadog.clusterName"
      value = var.cluster_name
    },
    {
      name  = "clusterAgent.token"
      value = random_password.cluster_agent_token.result
    }
  ]

  set = flatten([
    [
      for key, value in var.node_selector : {
        name  = "agents.nodeSelector.${key}"
        value = value
      }
    ],
    [
      for key, value in var.node_selector : {
        name  = "clusterAgent.nodeSelector.${key}"
        value = value
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "agents.tolerations[${key}].key"
        value = lookup(value, "key", "")
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "agents.tolerations[${key}].operator"
        value = lookup(value, "operator", "")
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "agents.tolerations[${key}].value"
        value = lookup(value, "value", "")
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "agents.tolerations[${key}].effect"
        value = lookup(value, "effect", "")
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "clusterAgent.tolerations[${key}].key"
        value = lookup(value, "key", "")
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "clusterAgent.tolerations[${key}].operator"
        value = lookup(value, "operator", "")
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "clusterAgent.tolerations[${key}].value"
        value = lookup(value, "value", "")
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "clusterAgent.tolerations[${key}].effect"
        value = lookup(value, "effect", "")
      }
    ],
  ])

  values = [local.manifest]

  lifecycle {
    ignore_changes = [
      timeout
    ]
  }
}
