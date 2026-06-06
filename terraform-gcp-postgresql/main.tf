/**
This `google_client_config` data source retrieves the current authenticated user's Google Cloud configuration.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
 */

data "google_client_config" "this" {}

/**
`google_compute_network` data source retrieves an existing network within Google Cloud Project from its name.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network
 */
data "google_compute_network" "this" {
  name = var.network_name
}

/**
`google_sql_database_instance` resource provisions a Google SQL Database instance.
This block creates a master instance.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
 */
resource "google_sql_database_instance" "primary" {
  project             = var.project_id
  name                = var.name
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.enabled_deletion_protection

  settings {
    tier                        = var.tier
    disk_autoresize             = var.enabled_disk_autoresize
    disk_size                   = var.size
    availability_type           = var.availability_type
    deletion_protection_enabled = var.enabled_deletion_protection
    user_labels                 = var.labels

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.this.id
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }

    backup_configuration {
      enabled    = true
      location   = var.backup_location
      start_time = var.daily_sql_instance_backup_start_time

      point_in_time_recovery_enabled = true
      transaction_log_retention_days = var.transaction_log_retention_days

      backup_retention_settings {
        retention_unit   = "COUNT"
        retained_backups = var.retained_backups_count
      }
    }

    maintenance_window {
      hour         = var.maintenance_window.hour
      update_track = var.maintenance_window.update_track
      day          = var.maintenance_window.day
    }
  }

  lifecycle {
    ignore_changes = [
      settings[0].ip_configuration,
      settings[0].disk_size
    ]
  }
}

/**
`google_sql_database_instance` resource provisions a Google SQL Database instance.
This block creates replica instance(s).
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
 */
resource "google_sql_database_instance" "replica" {
  count = var.replica_count

  project              = var.project_id
  name                 = "${var.name}-replica-${count.index}"
  region               = var.region
  database_version     = var.database_version
  deletion_protection  = var.enabled_deletion_protection
  master_instance_name = google_sql_database_instance.primary.name

  settings {
    tier                        = var.tier
    disk_autoresize             = var.enabled_disk_autoresize
    disk_size                   = var.size
    availability_type           = var.availability_type
    deletion_protection_enabled = var.enabled_deletion_protection
    user_labels                 = var.labels

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.this.id
    }

    insights_config {
      query_insights_enabled = true
      query_string_length    = 2048
    }

    dynamic "database_flags" {
      for_each = var.database_replica_flags

      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }
  }

  lifecycle {
    ignore_changes = [
      settings[0].ip_configuration,
      settings[0].disk_size
    ]
  }
}

/**
`google_sql_database_instance` resource provisions a Google SQL Database instance.
This block creates analytic replica instance(s).
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
 */
resource "google_sql_database_instance" "analytic_replica" {
  count = var.analytic_replica_count

  project              = var.project_id
  name                 = "${var.name}-analytic-replica-${count.index}"
  region               = var.region
  database_version     = var.database_version
  deletion_protection  = var.enabled_deletion_protection
  master_instance_name = google_sql_database_instance.primary.name

  settings {
    tier                        = var.tier
    disk_autoresize             = var.enabled_disk_autoresize
    disk_size                   = var.size
    availability_type           = var.availability_type
    deletion_protection_enabled = var.enabled_deletion_protection
    user_labels                 = var.labels

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.this.id
    }

    insights_config {
      query_insights_enabled = true
      query_string_length    = 2048
    }

    dynamic "database_flags" {
      for_each = merge(var.database_flags, local.analytic_replica_db_flags)

      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }
  }

  lifecycle {
    ignore_changes = [
      settings[0].ip_configuration,
      settings[0].disk_size
    ]
  }
}

/**
`google_sql_database` resource creates a SQL database inside the Cloud SQL instance, hosted in Google's cloud.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database.html
 */
resource "google_sql_database" "this" {
  instance = google_sql_database_instance.primary.name
  name     = var.db_name
}

/**
`random_string` generates a random permutation of alphanumeric characters and optionally special characters.
https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
 */
resource "random_string" "this" {
  count   = var.password == null ? 1 : 0
  length  = 24
  special = false
}

/**
`google_sql_user` resource creates a new Google SQL User on a Google SQL User Instance.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user
 */
resource "google_sql_user" "this" {
  name     = var.username
  instance = google_sql_database_instance.primary.name
  password = local.password
}
