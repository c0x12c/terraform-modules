terraform {
  required_version = ">= 1.10"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.55"
    }
  }
}

# Configure GRAFANA_URL and GRAFANA_AUTH in the environment.
provider "grafana" {}

module "tenant_dashboards" {
  source = "../../"

  project = "example"
  environments = {
    dev = {
      namespace    = "example-dev"
      service_name = "example-api"
      pod_regex    = "example-api-.*"
    }
    prod = {
      namespace    = "example-prod"
      service_name = "example-api"
      pod_regex    = "example-api-.*"
    }
  }

  # Explicitly use all default presets and RED threshold values.
  enabled_presets = ["pods", "runtime", "elasticache", "rds", "uptime", "red"]
  red_thresholds = {
    p95_seconds = 1
    error_ratio = 0.05
  }
}
