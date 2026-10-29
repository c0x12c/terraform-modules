mock_provider "aws" {}
mock_provider "kubernetes" {}
mock_provider "helm" {}
mock_provider "random" {}
mock_provider "cloudinit" {}

variables {
  eks_cluster_name = "example"
  tenants = {
    alpha = {
      topics             = { orders = {} }
      transactions       = true
      producer_byte_rate = 1000
      consumer_byte_rate = 2000
    }
    beta = {
      topics             = { events = {} }
      transactions       = true
      producer_byte_rate = 3000
      consumer_byte_rate = 4000
    }
  }
}

run "tenant_isolation" {
  command = plan

  assert {
    condition = alltrue(flatten([
      for tenant, config in yamldecode(helm_release.cluster.values[0]).tenants : [
        for acl in config.acls : startswith(acl.resource.name, "${tenant}.") && acl.resource.patternType == "prefixed"
      ]
    ])) && !strcontains(jsonencode(yamldecode(helm_release.cluster.values[0]).tenants.alpha), "beta.") && !strcontains(jsonencode(yamldecode(helm_release.cluster.values[0]).tenants.beta), "alpha.")
    error_message = "Every rendered tenant ACL must stay within its own dotted prefix."
  }

  assert {
    condition = yamldecode(helm_release.cluster.values[0]).quotas == [
      { user = "alpha", producer_byte_rate = 1000, consumer_byte_rate = 2000 },
      { user = "beta", producer_byte_rate = 3000, consumer_byte_rate = 4000 },
    ]
    error_message = "Both tenants must retain their own producer and consumer quotas."
  }

  assert {
    condition = yamldecode(helm_release.cluster.values[0]).clusterSpec.auth.sasl.enabled && alltrue([
      for listener in values(try(yamldecode(helm_release.cluster.values[0]).clusterSpec.listeners, {})) :
      try(listener.authenticationMethod == "sasl", false) && length(try(listener.external, {})) == 0
    ]) && !yamldecode(helm_release.cluster.values[0]).clusterSpec.external.enabled
    error_message = "Rendered listeners must require SASL and must not expose unauthenticated external listeners."
  }

  assert {
    condition     = yamldecode(helm_release.cluster.values[0]).clusterSpec.statefulset.nodeSelector["redpanda.com/cluster"] == "redpanda" && yamldecode(helm_release.cluster.values[0]).clusterSpec.statefulset.tolerations[0].effect == "NoSchedule"
    error_message = "Default placement must select the dedicated EC2 broker pool."
  }
}

run "invalid_tenant_name" {
  command = plan
  variables {
    tenants = { "1bad.name" = {} }
  }
  expect_failures = [var.tenants]
}

run "invalid_tenant_name_uppercase_dot" {
  command = plan
  variables {
    tenants = { "Bad.Name" = {} }
  }
  expect_failures = [var.tenants]
}

run "reserved_tenant_name_admin" {
  command = plan
  variables {
    tenants = { admin = {} }
  }
  expect_failures = [var.tenants]
}

run "zero_quota_rejected" {
  command = plan
  variables {
    tenants = { alpha = { producer_byte_rate = 0 } }
  }
  expect_failures = [var.tenants]
}

run "reserved_tenant_name_bootstrap" {
  command = plan
  variables {
    tenants = { kubernetes-controller = {} }
  }
  expect_failures = [var.tenants]
}

run "admin_api_auth_default" {
  command = plan

  assert {
    condition     = yamldecode(helm_release.cluster.values[0]).clusterSpec.config.cluster.admin_api_require_auth == true
    error_message = "Admin API authentication must be required by default."
  }
}

run "admin_api_auth_override" {
  command = plan
  variables {
    cluster_config = { admin_api_require_auth = false }
  }

  assert {
    condition     = yamldecode(helm_release.cluster.values[0]).clusterSpec.config.cluster.admin_api_require_auth == false
    error_message = "A caller's cluster_config must override the admin_api_require_auth default."
  }
}

run "bootstrap_user_secret" {
  command = plan

  assert {
    condition = (
      yamldecode(helm_release.cluster.values[0]).clusterSpec.auth.sasl.bootstrapUser.secretKeyRef.name == kubernetes_secret_v1.bootstrap.metadata[0].name &&
      yamldecode(helm_release.cluster.values[0]).clusterSpec.auth.sasl.bootstrapUser.secretKeyRef.name == "redpanda-bootstrap-user-tf" &&
      yamldecode(helm_release.cluster.values[0]).clusterSpec.auth.sasl.bootstrapUser.secretKeyRef.key == "password" &&
      yamldecode(helm_release.cluster.values[0]).clusterSpec.auth.sasl.bootstrapUser.name == "kubernetes-controller" &&
      yamldecode(helm_release.cluster.values[0]).clusterSpec.auth.sasl.bootstrapUser.mechanism == "SCRAM-SHA-512"
    )
    error_message = "The operator's bootstrap user must read its password from the Terraform-managed secret."
  }
}

run "console_without_impersonation" {
  command = plan
  variables {
    console_enabled = true
  }

  assert {
    condition = (
      yamldecode(helm_release.cluster.values[0]).clusterSpec.console.enabled == true &&
      yamldecode(helm_release.cluster.values[0]).clusterSpec.console.console.kafka.sasl.impersonateUser == false &&
      contains(
        yamldecode(helm_release.cluster.values[0]).clusterSpec.console.extraEnv,
        { name = "REDPANDA_ADMINAPI_AUTHENTICATION_IMPERSONATEUSER", value = "false" },
      )
    )
    error_message = "Console must not impersonate users: no Enterprise licence means no per-user login."
  }
}

run "external_pool" {
  command = plan
  variables {
    node_group = {
      labels = { "pool" = "brokers" }
      taint  = { key = "workload", value = "brokers" }
    }
  }
  assert {
    condition     = yamldecode(helm_release.cluster.values[0]).clusterSpec.statefulset.nodeSelector.pool == "brokers" && yamldecode(helm_release.cluster.values[0]).clusterSpec.statefulset.tolerations[0].key == "workload"
    error_message = "External pool labels and taint must reach broker scheduling."
  }
}
