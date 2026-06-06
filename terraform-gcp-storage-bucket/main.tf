locals {
  bucket_name = var.bucket_name_overwrite == null ? "${var.bucket_name}-${var.environment}" : var.bucket_name_overwrite
}

/**
`google_storage_bucket` creates a new bucket in Google cloud storage service (GCS).
Once a bucket has been created, its location can't be changed.
With customizable options such as versioning, static website hosting, and CORS settings based on input variables.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
 */
resource "google_storage_bucket" "this" {
  name          = local.bucket_name
  location      = var.location
  force_destroy = var.force_destroy
  storage_class = var.storage_class

  uniform_bucket_level_access = var.uniform_bucket_level_access
  public_access_prevention    = var.public_access_prevention

  dynamic "soft_delete_policy" {
    for_each = var.soft_delete_policy != null ? [var.soft_delete_policy] : []
    content {
      retention_duration_seconds = soft_delete_policy.value.retention_duration_seconds
    }
  }

  versioning {
    enabled = var.enable_versioning
  }

  dynamic "website" {
    for_each = var.is_static_web ? ["website"] : []
    content {
      main_page_suffix = var.main_page_suffix
      not_found_page   = var.not_found_page
    }
  }

  dynamic "cors" {
    for_each = var.enable_cors ? ["cors"] : []

    content {
      origin          = var.cors_origins
      method          = var.cors_methods
      response_header = var.cors_extra_headers
      max_age_seconds = var.cors_max_age_seconds
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules

    content {
      condition {
        age                        = lifecycle_rule.value.age
        days_since_noncurrent_time = lifecycle_rule.value.days_since_noncurrent_time
      }
      action {
        type = lifecycle_rule.value.type
      }
    }
  }

  dynamic "logging" {
    for_each = var.logging != null ? [1] : []
    content {
      log_bucket        = logging.value.destination_bucket
      log_object_prefix = "${local.bucket_name}/"
    }
  }
}

/**
`google_storage_bucket_access_control` sets access on bucket level.
This block grants read access to all users for specified GCS bucket.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_access_control
 */
resource "google_storage_bucket_access_control" "public_rule" {
  count = var.is_listable == true ? 1 : 0

  bucket = google_storage_bucket.this.name
  role   = "READER"
  entity = "allUsers"
}

/**
`google_storage_default_object_access_control` sets default access on objects within a GCS bucket.
This block sets default read access for all users on objects within a GCS bucket.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_default_object_access_control
 */
resource "google_storage_default_object_access_control" "public_rule" {
  count = var.is_public == true ? 1 : 0

  bucket = google_storage_bucket.this.name
  role   = "READER"
  entity = "allUsers"
}
