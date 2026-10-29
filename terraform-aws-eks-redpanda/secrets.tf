# Passwords are generated here, so they live in Terraform state: keep the state encrypted
# and access-controlled, as for any module that creates credentials.
resource "random_password" "admin" {
  length  = 32
  special = false
}

resource "random_password" "bootstrap" {
  length  = 32
  special = false
}

resource "random_password" "tenant" {
  for_each = var.tenants

  length  = 32
  special = false
}

resource "kubernetes_secret_v1" "superusers" {
  metadata {
    name      = local.superusers_secret
    namespace = var.namespace
  }
  data = {
    "superusers.txt" = "admin:${random_password.admin.result}:SCRAM-SHA-512"
  }
  depends_on = [kubernetes_namespace_v1.this]
}

resource "kubernetes_secret_v1" "admin" {
  metadata {
    name      = local.admin_secret
    namespace = var.namespace
  }
  data = {
    username  = "admin"
    password  = random_password.admin.result
    mechanism = "SCRAM-SHA-512"
  }
  depends_on = [kubernetes_namespace_v1.this]
}

resource "kubernetes_secret_v1" "bootstrap" {
  metadata {
    name      = local.bootstrap_secret
    namespace = var.namespace
  }
  data = {
    password = random_password.bootstrap.result
  }
  depends_on = [kubernetes_namespace_v1.this]
}

resource "kubernetes_secret_v1" "tenant" {
  for_each = var.tenants

  metadata {
    name      = local.tenant_secrets[each.key]
    namespace = var.namespace
  }
  data = {
    username  = each.key
    password  = random_password.tenant[each.key].result
    mechanism = "SCRAM-SHA-512"
    brokers   = local.brokers_address
  }
  depends_on = [kubernetes_namespace_v1.this]
}
