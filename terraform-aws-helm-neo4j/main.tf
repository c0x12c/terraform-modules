resource "random_password" "neo4j_password" {
  count   = var.neo4j_password == null ? 1 : 0
  length  = 24
  special = false
}

locals {
  neo4j_config = var.custom_neo4j_config != null ? var.custom_neo4j_config : templatefile("${path.module}/scripts/neo4j-config.conf", local.neo4j_config_vars)
  neo4j_config_vars = {
    DEFAULT_ADVERTISED_ADDRESS = local.default_fqdn
    NEO4J_PROCEDURES           = var.neo4j_procedures
  }
  manifest = <<-YAML
resources:
  requests:
    cpu: ${var.neo4j_cpu}
    memory: ${var.neo4j_memory}
  limits:
    cpu: ${var.neo4j_cpu}
    memory: ${var.neo4j_memory}
customReadinessProbe:
  failureThreshold: 20
  httpGet:
    path: /
    port: http
    scheme: HTTP
  initialDelaySeconds: 30
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 10
customLivenessProbe:
  failureThreshold: 20
  initialDelaySeconds: 30
  periodSeconds: 10
  successThreshold: 1
  tcpSocket:
    port: bolt
  timeoutSeconds: 10
initContainers:
- command:
  - sh
  - -c
  - |
    apk add --no-cache wget && \
    %{for url in var.neo4j_plugins~}
wget -O ${var.neo4j_plugins_dir}/${basename(url)} ${url}
    %{endfor}
  image: alpine
  imagePullPolicy: Always
  name: init-plugin
  resources: {}
  terminationMessagePath: /dev/termination-log
  terminationMessagePolicy: File
  volumeMounts:
  - mountPath: ${var.neo4j_plugins_dir}
    name: empty-dir
    subPath: app-plugins-dir
configuration: |-
${indent(2, local.neo4j_config)}
ingress:
  enabled: true
  annotations:
    alb.ingress.kubernetes.io/group.name: ${var.ingress_group_name}
    kubernetes.io/ingress.class: ${var.ingress_class_name}
    alb.ingress.kubernetes.io/target-type: "ip"
    alb.ingress.kubernetes.io/scheme: "internet-facing"
    alb.ingress.kubernetes.io/listen-ports: "[{\"HTTP\": 7474}, {\"HTTPS\": 443}]"
  hostname: ${local.neo4j_fqdn}
  path: /*
service:
  type: ClusterIP
persistence:
  storageClass: ${var.efs_storage_class_name}
  existingClaim: ${kubernetes_persistent_volume_claim.neo4j_home.metadata.0.name}
  accessModes:
    - ReadWriteMany
YAML
}

resource "helm_release" "neo4j" {
  name             = var.helm_release_name
  chart            = "neo4j"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  version          = var.chart_version
  create_namespace = var.create_namespace
  namespace        = var.namespace
  force_update     = var.force_update
  timeout          = 1000

  set = flatten([
    [{
      name  = "auth.password"
      value = local.neo4j_password
    }],
    [for key, value in var.node_selector : {
      name  = "nodeSelector.${key}"
      value = value
    }],
    [for key, value in var.tolerations : {
      name  = "podSpec.tolerations[${key}].key"
      value = lookup(value, "key", "")
    }],
    [for key, value in var.tolerations : {
      name  = "podSpec.tolerations[${key}].operator"
      value = lookup(value, "operator", "")
    }],
    [for key, value in var.tolerations : {
      name  = "podSpec.tolerations[${key}].value"
      value = lookup(value, "value", "")
    }],
    [for key, value in var.tolerations : {
      name  = "podSpec.tolerations[${key}].effect"
      value = lookup(value, "effect", "")
    }]
  ])

  values = [local.manifest]

  depends_on = [kubernetes_persistent_volume.neo4j_home]

  lifecycle {
    ignore_changes = [
      timeout
    ]
  }
}
