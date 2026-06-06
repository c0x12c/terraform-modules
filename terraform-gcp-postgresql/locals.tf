locals {
  password = var.password != null ? var.password : random_string.this.0.result
  analytic_replica_db_flags = {
    "max_standby_streaming_delay" = "300000" // 300s
    "max_standby_archive_delay"   = "300000" // 300s
  }
}
