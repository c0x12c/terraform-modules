locals {
  postgres_parameters = {
    "max_worker_processes" = {
      value = lookup(local.max_workers, var.instance_class, 8), apply_method = "pending-reboot"
    }
    "max_parallel_workers" = {
      value = lookup(local.max_workers, var.instance_class, 8), apply_method = "pending-reboot"
    }
    "rds.logical_replication" = { value = "1", apply_method = "pending-reboot" }
    "max_wal_senders"         = { value = "10", apply_method = "pending-reboot" }
    "max_sync_workers_per_subscription" = {
      value = floor(lookup(local.max_workers, var.instance_class, 8) * 0.5), apply_method = "immediate"
    }
    "max_logical_replication_workers" = {
      value = floor(lookup(local.max_workers, var.instance_class, 8) * 0.5), apply_method = "pending-reboot"
    }
    "max_wal_size"              = { value = "10240", apply_method = "immediate" }
    "max_replication_slots"     = { value = "10", apply_method = "pending-reboot" }
    "shared_preload_libraries"  = { value = "pg_stat_statements,pg_cron,pgaudit", apply_method = "pending-reboot" }
    "pg_stat_statements.track"  = { value = "ALL", apply_method = "pending-reboot" }
    "pg_stat_statements.max"    = { value = "10000", apply_method = "pending-reboot" }
    "track_activity_query_size" = { value = "4096", apply_method = "pending-reboot" }
    "cron.database_name"        = { value = var.db_name, apply_method = "pending-reboot" }
  }
}

resource "aws_db_parameter_group" "parameter_group" {
  for_each = {
    for _, version in distinct(concat(var.supported_engine_version, [local.engine_version_major])) : version => version
  }

  name   = "${local.identifier}-${replace(each.key, ".", "-")}"
  family = "${var.engine}${each.key}"

  dynamic "parameter" {
    for_each = var.engine == "postgres" ? merge(local.postgres_parameters, var.additional_postgres_parameters) : {}
    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
