mock_provider "aws" {}
mock_provider "kubernetes" {}
mock_provider "helm" {}
mock_provider "random" {}
mock_provider "cloudinit" {}

variables {
  eks_cluster_name = "example"
}

run "off_by_default" {
  command = plan

  assert {
    condition = (
      length(helm_release.monitoring) == 0 &&
      !can(yamldecode(helm_release.cluster.values[0]).clusterSpec.monitoring) &&
      !can(yamldecode(helm_release.operator[0].values[0]).monitoring)
    )
    error_message = "Monitoring must stay off, and render nothing, unless it is enabled."
  }
}

run "enabled" {
  command = plan
  variables {
    monitoring = {
      enabled                   = true
      scrape_interval           = "15s"
      lag_messages              = 5000
      lag_excluded_groups_regex = ".*verify.*"
    }
  }

  assert {
    condition = (
      yamldecode(helm_release.cluster.values[0]).clusterSpec.monitoring == { enabled = true, scrapeInterval = "15s" } &&
      yamldecode(helm_release.operator[0].values[0]).monitoring.enabled == true &&
      length(helm_release.monitoring) == 1
    )
    error_message = "Enabling monitoring must wire the broker monitor, the operator monitor and the rules release."
  }

  assert {
    condition = (
      yamldecode(helm_release.monitoring[0].values[0]).replicas == yamldecode(helm_release.cluster.values[0]).clusterSpec.statefulset.replicas &&
      yamldecode(helm_release.monitoring[0].values[0]).monitoring.lagMessages == 5000 &&
      yamldecode(helm_release.monitoring[0].values[0]).monitoring.lagExcludedGroupsRegex == ".*verify.*" &&
      yamldecode(helm_release.monitoring[0].values[0]).monitoring.dashboardNamespace == "monitoring"
    )
    error_message = "The broker-down rule must count the real broker number, and thresholds must reach the chart."
  }
}
