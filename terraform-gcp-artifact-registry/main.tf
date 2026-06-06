/**
`google_artifact_registry_repository` resource provisions an Artifact Registry.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository
 */
resource "google_artifact_registry_repository" "this" {
  repository_id = var.repository_id
  location      = var.location
  format        = var.format
  project       = var.project_id
  mode          = var.mode
  description   = var.description
  labels        = var.labels

  kms_key_name = var.kms_key_name

  dynamic "docker_config" {
    for_each = var.docker_config[*]
    content {
      immutable_tags = docker_config.value.immutable_tags
    }
  }

  dynamic "maven_config" {
    for_each = var.maven_config[*]
    content {
      allow_snapshot_overwrites = maven_config.value.allow_snapshot_overwrites
      version_policy            = maven_config.value.version_policy
    }
  }

  dynamic "virtual_repository_config" {
    for_each = var.virtual_repository_config[*]
    content {
      dynamic "upstream_policies" {
        for_each = virtual_repository_config.value.upstream_policies[*]
        content {
          id         = upstream_policies.value.id
          repository = upstream_policies.value.repository
          priority   = upstream_policies.value.priority
        }
      }
    }
  }

  dynamic "remote_repository_config" {
    for_each = var.remote_repository_config[*]
    content {
      description = remote_repository_config.value.description

      dynamic "apt_repository" {
        for_each = remote_repository_config.value.apt_repository[*]
        content {
          dynamic "public_repository" {
            for_each = apt_repository.value.public_repository[*]
            content {
              repository_base = public_repository.value.repository_base
              repository_path = public_repository.value.repository_path
            }
          }
        }
      }

      dynamic "docker_repository" {
        for_each = remote_repository_config.value.docker_repository[*]
        content {
          public_repository = docker_repository.value.public_repository
        }
      }

      dynamic "maven_repository" {
        for_each = remote_repository_config.value.maven_repository[*]
        content {
          public_repository = maven_repository.value.public_repository
        }
      }

      dynamic "npm_repository" {
        for_each = remote_repository_config.value.npm_repository[*]
        content {
          public_repository = npm_repository.value.public_repository
        }
      }

      dynamic "python_repository" {
        for_each = remote_repository_config.value.python_repository[*]
        content {
          public_repository = python_repository.value.public_repository
        }
      }

      dynamic "yum_repository" {
        for_each = remote_repository_config.value.yum_repository[*]
        content {
          dynamic "public_repository" {
            for_each = yum_repository.value.public_repository[*]
            content {
              repository_base = public_repository.value.repository_base
              repository_path = public_repository.value.repository_path
            }
          }
        }
      }
    }
  }

  cleanup_policy_dry_run = var.cleanup_policy_dry_run

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      id     = cleanup_policies.key
      action = cleanup_policies.value.action

      dynamic "condition" {
        for_each = cleanup_policies.value.condition[*]
        content {
          tag_state             = condition.value.tag_state
          tag_prefixes          = condition.value.tag_prefixes
          older_than            = condition.value.older_than
          newer_than            = condition.value.newer_than
          version_name_prefixes = condition.value.version_name_prefixes
          package_name_prefixes = condition.value.package_name_prefixes
        }
      }

      dynamic "most_recent_versions" {
        for_each = cleanup_policies.value.most_recent_versions[*]
        content {
          keep_count            = most_recent_versions.value.keep_count
          package_name_prefixes = most_recent_versions.value.package_name_prefixes
        }
      }
    }
  }
}

/**
`google_artifact_registry_vpcsc_config` resource provisions/updates (existing) Artifact Registry VPC Security Policy; prevent unauthorized access or data exfiltration, ensuring that only requests from allowed networks or projects can interact with the registry.
[NOTE] VPC SC configs are automatically created for a given location. Creating a resource of this type will acquire and update the resource that already exists at the location. Deleting this resource will remove the config from your Terraform state but leave the resource as is.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_vpcsc_config
 */
resource "google_artifact_registry_vpcsc_config" "this" {
  count = var.enable_vpcsc_policy ? 1 : 0

  provider     = google-beta
  vpcsc_policy = var.vpcsc_policy
  location     = google_artifact_registry_repository.this.location
  project      = google_artifact_registry_repository.this.project
}

/**
`google_artifact_registry_repository_iam_member` grant the Artifact Registry Reader role to members.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam#google_artifact_registry_repository_iam_member
 */
resource "google_artifact_registry_repository_iam_member" "readers" {
  for_each   = toset(contains(keys(var.members), "readers") ? var.members["readers"] : [])
  project    = google_artifact_registry_repository.this.project
  location   = google_artifact_registry_repository.this.location
  repository = google_artifact_registry_repository.this.name

  role   = "roles/artifactregistry.reader"
  member = each.value

  depends_on = [
    google_artifact_registry_repository.this
  ]
}

/**
`google_artifact_registry_repository_iam_member` grant the Artifact Registry Writer role to members.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam#google_artifact_registry_repository_iam_member
 */
resource "google_artifact_registry_repository_iam_member" "writers" {
  for_each   = toset(contains(keys(var.members), "writers") ? var.members["writers"] : [])
  project    = google_artifact_registry_repository.this.project
  location   = google_artifact_registry_repository.this.location
  repository = google_artifact_registry_repository.this.name

  role   = "roles/artifactregistry.writer"
  member = each.value

  depends_on = [
    google_artifact_registry_repository.this
  ]
}
