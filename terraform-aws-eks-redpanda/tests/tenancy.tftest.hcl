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
