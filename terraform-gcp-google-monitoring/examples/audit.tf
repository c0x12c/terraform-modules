module "audit_alert" {
  source = "../../google-monitoring"

  name          = "audit-metric"
  description   = "Detects audit changes"
  filter        = <<EOT
protoPayload.methodName="SetIamPolicy" AND protoPayload.serviceData.policyDelta.auditConfigDeltas:*
EOT
  resource_type = "audited_resource"

  metric_kind = "DELTA"
  value_type  = "INT64"
  unit        = "1"

  combiner = "OR"

  conditions = [
    {
      display_name    = "Audit Change Detected"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  ]

  user_labels = {
    purpose = "audit-alerting"
  }
}
