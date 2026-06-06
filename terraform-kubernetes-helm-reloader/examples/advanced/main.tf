module "reloader" {
  source = "../../"

  namespace = "reloader-system"

  # Reloader Configuration
  watch_globally  = true
  reload_strategy = "annotations" # Use annotations strategy for GitOps
  log_level       = "info"
  log_format      = "json"

  # Resource Filtering
  ignore_configmaps    = true # Ignore ConfigMaps, only watch Secrets
  ignore_jobs          = true
  ignore_cronjobs      = true
  namespaces_to_ignore = "kube-system,kube-public"

  # Additional Configuration
  enable_ha                   = true # Enable high availability
  enable_metrics_by_namespace = true # Enable Prometheus metrics

  # Resource Configuration
  replica_count = 2
  resources = {
    requests = {
      cpu    = "50m"
      memory = "64Mi"
    }
    limits = {
      cpu    = "200m"
      memory = "256Mi"
    }
  }

  # Node Selection
  node_selector = {
    "node-role.kubernetes.io/worker" = "true"
  }

  # Tolerations
  tolerations = [
    {
      key      = "node-role.kubernetes.io/control-plane"
      operator = "Exists"
      effect   = "NoSchedule"
    }
  ]

  # Security Context
  security_context = {
    run_as_non_root = true
    run_as_user     = 65534
    run_as_group    = 65534
    fs_group        = 65534
  }

  # Labels
  labels = {
    "app.kubernetes.io/part-of" = "platform"
    "environment"               = "production"
  }
}
