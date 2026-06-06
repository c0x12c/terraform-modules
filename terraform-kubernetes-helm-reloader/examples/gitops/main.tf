module "reloader" {
  source = "../../"

  namespace = "reloader-system"

  # GitOps-friendly configuration
  reload_strategy = "annotations" # Prevents config drift in ArgoCD/Flux
  log_format      = "json"        # Better for log aggregation

  # Only watch specific namespaces
  watch_globally     = false
  namespace_selector = "environment=production"

  # Ignore system namespaces
  namespaces_to_ignore = "kube-system,kube-public,kube-node-lease"

  # Additional GitOps Configuration
  is_argo_rollouts            = true # Enable Argo Rollouts support
  enable_metrics_by_namespace = true # Enable Prometheus metrics

  # Resource Configuration
  replica_count = 1
  resources = {
    requests = {
      cpu    = "10m"
      memory = "32Mi"
    }
    limits = {
      cpu    = "100m"
      memory = "128Mi"
    }
  }

  # Security Context
  security_context = {
    run_as_non_root = true
    run_as_user     = 65534
    run_as_group    = 65534
    fs_group        = 65534
  }

  # Labels for GitOps
  labels = {
    "app.kubernetes.io/part-of" = "gitops"
    "environment"               = "production"
    "managed-by"                = "argocd"
  }
}
