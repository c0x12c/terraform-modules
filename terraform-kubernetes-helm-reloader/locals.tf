locals {
  # Build the Helm values manifest
  manifest = yamlencode({
    image = {
      repository = var.image_repository
      tag        = var.image_tag
      pullPolicy = var.image_pull_policy
    }

    reloader = {
      autoReloadAll            = var.auto_reload_all
      isArgoRollouts           = var.is_argo_rollouts
      isOpenshift              = var.is_openshift
      ignoreSecrets            = var.ignore_secrets
      ignoreConfigMaps         = var.ignore_configmaps
      ignoreJobs               = var.ignore_jobs
      ignoreCronJobs           = var.ignore_cronjobs
      reloadOnCreate           = var.reload_on_create
      reloadOnDelete           = var.reload_on_delete
      syncAfterRestart         = var.sync_after_restart
      reloadStrategy           = var.reload_strategy
      ignoreNamespaces         = var.namespaces_to_ignore
      namespaceSelector        = var.namespace_selector
      resourceLabelSelector    = var.resource_label_selector
      logFormat                = var.log_format
      logLevel                 = var.log_level
      watchGlobally            = var.watch_globally
      enableHA                 = var.enable_ha
      enablePProf              = var.enable_pprof
      pprofAddr                = var.pprof_addr
      readOnlyRootFileSystem   = var.read_only_root_filesystem
      enableMetricsByNamespace = var.enable_metrics_by_namespace

      deployment = {
        replicas                 = var.replica_count
        nodeSelector             = var.node_selector
        tolerations              = var.tolerations
        affinity                 = var.affinity
        securityContext          = var.security_context
        containerSecurityContext = var.pod_security_context
        resources                = var.resources
      }

      rbac = {
        enabled = true
      }

      serviceAccount = {
        create      = true
        name        = "reloader"
        annotations = {}
      }
    }
  })
}
