locals {
  cluster_roles_count  = length(var.cluster_roles)
  profile_roles_count  = length(var.profile_roles)
  namespace_role_count = length(var.namespace_roles)

  namespace_privileges = {
    admin = {
      rules = [
        {
          api_groups = ["*"]
          resources  = ["*"]
          verbs      = ["*"]
        }
      ]
    }
    readonly = {
      rules = [
        {
          api_groups = ["*"]
          resources  = ["pods", "pods/log", "services", "jobs", "configmaps", "endpoints", "events", "deployments", "ingresses"]
          verbs      = ["get", "list", "watch"]
        }
      ]
    }
    developer = {
      rules = [
        {
          api_groups = ["*"]
          resources  = ["pods", "pods/log", "pods/exec", "services", "jobs", "configmaps", "secrets", "endpoints", "events", "deployments", "ingresses"]
          verbs      = ["get", "list", "watch", "create", "update", "delete"]
        }
      ]
    }
  }

  cluster_privileges = {
    admin = {
      rules = [
        {
          api_groups = ["*"]
          resources  = ["*"]
          verbs      = ["*"]
        },
        {
          non_resource_urls = ["*"]
          verbs             = ["*"]
        }

      ]
    }
    readonly = {
      rules = [
        {
          api_groups = ["*"]
          resources  = ["pods", "services", "namespaces", "deployments", "jobs", "nodes", "ingresses", "events", "configmaps", "endpoints"]
          verbs      = ["get", "list", "watch"]
        }
      ]
    }
    developer = {
      rules = [
        {
          api_groups = ["*"]
          resources  = ["namespaces", "nodes"]
          verbs      = ["get", "list", "watch"]
        },
        {
          api_groups = ["*"]
          resources  = ["pods", "pods/log", "pods/exec", "services", "jobs", "configmaps", "secrets", "endpoints", "events", "deployments", "ingresses"]
          verbs      = ["get", "list", "watch", "create", "update", "delete"]
        }
      ]
    }
  }
}
