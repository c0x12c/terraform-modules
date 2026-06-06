locals {
  predefined_rules = {
    admin = [
      "applications, *",
      "applicationsets, *",
      "repositories, *",
      "exec, *",
      "clusters, *",
      "logs, *",
    ],
    member = [
      "applications, *",
      "applicationsets, *",
      "repositories, get",
      "clusters, get",
      "logs, get",
    ],
    viewer = [
      "applications, get",
      "applicationsets, get",
      "repositories, get",
      "clusters, get",
      "logs, get",
    ]
  }

  predefined_group = merge(
    [for role, groups in var.predefined_group_rules : {
      for group_name in toset(groups) :
      group_name => local.predefined_rules[role]
    }]...
  )

  group_roles = merge(
    local.predefined_group,
    var.custom_group_roles
  )
}


resource "terraform_data" "project_spec_hash" {
  input = sha256(jsonencode({
    description                  = var.description
    sourceRepos                  = var.source_repos
    destinations                 = var.destinations
    argocd_namespace             = var.argocd_namespace
    project_name                 = var.project_name
    github_organization          = var.github_organization
    group_roles                  = local.group_roles
    cluster_resource_whitelist   = var.cluster_resource_whitelist
    namespace_resource_whitelist = var.namespace_resource_whitelist
    cluster_resource_blacklist   = var.cluster_resource_blacklist
    namespace_resource_blacklist = var.namespace_resource_blacklist
  }))
}

resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"

    metadata = {
      namespace = var.argocd_namespace
      name      = var.project_name
    }

    spec = merge(
      {
        description = var.description
        sourceRepos = var.source_repos
        destinations = concat(
          var.destinations,
          [{
            name      = "in-cluster"
            namespace = var.argocd_namespace
          }]
        )
        roles = [
          for group, roles in local.group_roles : {
            name     = group
            groups   = ["${var.github_organization}:${group}"]
            policies = [for role in roles : "p, proj:${var.project_name}:${group}, ${role}, ${var.project_name}/*, allow"]
          }
        ]
      },
      length(var.cluster_resource_whitelist) > 0 ? {
        clusterResourceWhitelist = var.cluster_resource_whitelist
      } : {},
      length(var.namespace_resource_whitelist) > 0 ? {
        namespaceResourceWhitelist = var.namespace_resource_whitelist
      } : {},
      length(var.cluster_resource_blacklist) > 0 ? {
        clusterResourceBlacklist = var.cluster_resource_blacklist
      } : {},
      length(var.namespace_resource_blacklist) > 0 ? {
        namespaceResourceBlacklist = var.namespace_resource_blacklist
      } : {},
    )
  }

  computed_fields = [
    "metadata.annotations",
    "metadata.labels",
    "metadata.finalizers",
  ]

  field_manager {
    force_conflicts = true
  }

  lifecycle {
    replace_triggered_by = [terraform_data.project_spec_hash]
  }
}

resource "kubernetes_manifest" "app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = var.project_name
      namespace = var.argocd_namespace
    }

    spec = {
      project = var.project_name

      source = {
        repoURL        = var.repo_url
        path           = var.path
        targetRevision = var.target_revision
        directory = {
          recurse = true
        }
      }

      destination = {
        name      = "in-cluster"
        namespace = var.argocd_namespace
      }

      syncPolicy = var.sync_policy
    }
  }

  computed_fields = [
    "metadata.annotations",
    "metadata.labels",
    "metadata.finalizers",
    "spec.operation",
  ]

  field_manager {
    force_conflicts = true
  }

  depends_on = [kubernetes_manifest.this]
}
