/**
Please navigate to README.md before apply this example
 */
module "custom_role_change_alert" {
  source = "../../google-monitoring"

  name        = "custom-role-change-metric"
  description = "Detects custom role changes"
  filter      = <<EOT
resource.type="iam_role"
AND (
  protoPayload.methodName="google.iam.admin.v1.CreateRole"
  OR protoPayload.methodName="google.iam.admin.v1.DeleteRole"
  OR protoPayload.methodName="google.iam.admin.v1.UpdateRole"
)
EOT

  resource_type = "global"

  metric_kind = "DELTA"
  value_type  = "INT64"
  unit        = "1"

  combiner = "OR"

  conditions = [
    {
      display_name    = "Custom Role Change Detected"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  ]

  user_labels = {
    purpose = "custom-role-alerting"
  }
}
