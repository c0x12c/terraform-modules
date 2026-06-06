data "google_client_config" "this" {}

locals {
  default_postgres_monitor = {
    postgres_cpu_monitor = {
      priority_level = 2
      title_tags     = "[High CPU Utilization] [PostgreSQL]"
      title          = "GCP - PostgreSQL - CPU usage is too high."

      query_template = "max($${timeframe}):max:gcp.cloudsql.database.cpu.utilization{project_id:${data.google_client_config.this.project}} by {database_id} >= $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 80
      threshold_critical_recovery = 70
      renotify_interval           = 30
    }

    postgres_memory_monitor = {
      priority_level = 2
      title_tags     = "[High Memory Utilization] [PostgreSQL]"
      title          = "GCP - PostgreSQL - Memory usage is too high."

      query_template = "max($${timeframe}):max:gcp.cloudsql.database.memory.total_usage{project_id:${data.google_client_config.this.project}} by {database_id} / max:gcp.cloudsql.database.memory.quota{project_id:${data.google_client_config.this.project}} by {database_id} > $${threshold_critical}"
      query_args = {
        timeframe = "last_5m"
      }

      threshold_critical          = 80
      threshold_critical_recovery = 70
      renotify_interval           = 30
    }

    postgres_uptime_monitor = {
      priority_level = 1
      title_tags     = "[Uptime] [PostgreSQL]"
      title          = "GCP - PostgreSQL - Database is not healthy."

      query_template = "min($${timeframe}):sum:gcp.cloudsql.database.uptime{project_id:${data.google_client_config.this.project}} by {database_id} < $${threshold_critical}"
      query_args = {
        timeframe = "last_1m"
      }

      threshold_critical          = 55
      threshold_critical_recovery = 59
      renotify_interval           = 10
    }
  }
}
