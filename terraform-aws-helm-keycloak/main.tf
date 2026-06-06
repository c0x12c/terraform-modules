resource "random_password" "keycloak_password" {
  length  = 32
  special = false
}

resource "random_password" "postgresql_password" {
  count   = var.create_postgresql == true ? 1 : 0
  length  = 32
  special = false
}

locals {
  keycloak_username   = "admin"
  keycloak_password   = random_password.keycloak_password.result
  postgresql_password = var.create_postgresql == true ? random_password.postgresql_password[0].result : var.postgresql_password

  manifest = <<-YAML
resources:
  requests:
    cpu: ${var.keycloak_cpu}
    memory: ${var.keycloak_memory}
  limits:
    cpu: ${var.keycloak_cpu}
    memory: ${var.keycloak_memory}
ingress:
  enabled: ${var.create_ingress}
  ingressClassName: ${var.ingress_class_name}
  annotations:
    alb.ingress.kubernetes.io/group.name: ${var.ingress_group_name}
    kubernetes.io/ingress.class: ${var.ingress_class_name}
    alb.ingress.kubernetes.io/target-type: "ip"
    alb.ingress.kubernetes.io/scheme: "internet-facing"
    alb.ingress.kubernetes.io/listen-ports: "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
  hostname: ${var.ingress_hostname}
  pathType: Prefix
service:
  type: ClusterIP
production: true
proxyHeaders: "xforwarded"
YAML
}

resource "helm_release" "keycloak" {
  name             = var.helm_release_name
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "keycloak"
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = var.create_namespace
  keyring          = ""

  set = flatten([
    [
      {
        name  = "auth.adminUser"
        value = local.keycloak_username
      },
      {
        name  = "auth.adminPassword"
        value = local.keycloak_password
      },
      {
        name  = "global.defaultStorageClass"
        value = var.storage_class_name
      },
    ],
    [
      for key, value in var.create_postgresql == true ? {
        "postgresql.enabled"               = true
        "postgresql.auth.database"         = var.postgresql_db_name
        "postgresql.auth.postgresPassword" = local.postgresql_password
        "postgresql.auth.username"         = var.postgresql_username
        "postgresql.auth.password"         = local.postgresql_password
        } : {
        "postgresql.enabled"        = false
        "externalDatabase.host"     = var.postgresql_host
        "externalDatabase.user"     = var.postgresql_username
        "externalDatabase.database" = var.postgresql_db_name
        "externalDatabase.password" = local.postgresql_password
        } : {
        name  = key
        value = value
      }
    ],
    [
      for key, value in var.node_selector : {
        name  = "nodeSelector.${key}"
        value = value
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "tolerations[${key}].key"
        value = lookup(value, "key", "")
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "tolerations[${key}].operator"
        value = lookup(value, "operator", "")
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "tolerations[${key}].value"
        value = lookup(value, "value", "")
      }
    ],
    [
      for key, value in var.tolerations : {
        name  = "tolerations[${key}].effect"
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
