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


resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"

    metadata = {
      namespace = var.argocd_namespace
      name      = var.project_name
    }

    spec = {
      description = var.description
      sourceRepos = ["*"]
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
    }
  }

  lifecycle {
    ignore_changes = [
      manifest.spec.destinations
    ]
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
  depends_on = [kubernetes_manifest.this]
}
