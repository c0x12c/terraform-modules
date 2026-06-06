module "storage_bucket_permission_change_alert" {
  source = "../../google-monitoring"

  name          = "storage-bucket-permission-change-metric"
  description   = "Detects Storage Bucket permission changes"
  filter        = <<EOT
resource.type=gcs_bucket AND protoPayload.methodName="storage.setIamPermissions"
EOT
  resource_type = "gcs_bucket"

  metric_kind = "DELTA"
  value_type  = "INT64"
  unit        = "1"

  combiner = "OR"

  conditions = [
    {
      display_name    = "Storage Bucket Permission Change Detected"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  ]

  user_labels = {
    purpose = "storage-bucket-alerting"
  }
}
