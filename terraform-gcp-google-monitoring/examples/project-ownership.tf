module "project_ownership_change_alert" {
  source = "../../google-monitoring"

  name          = "project-ownership-change-metric"
  description   = "Detects Project ownership changes"
  filter        = <<EOT
protoPayload.serviceName="cloudresourcemanager.googleapis.com"
AND (
  ProjectOwnership
  OR projectOwnerInvitee
  OR (
    protoPayload.serviceData.policyDelta.bindingDeltas.action="REMOVE"
    AND protoPayload.serviceData.policyDelta.bindingDeltas.role="roles/owner"
  )
  OR (
    protoPayload.serviceData.policyDelta.bindingDeltas.action="ADD"
    AND protoPayload.serviceData.policyDelta.bindingDeltas.role="roles/owner"
  )
)
EOT
  resource_type = "audited_resource"

  metric_kind = "DELTA"
  value_type  = "INT64"
  unit        = "1"

  combiner = "OR"

  conditions = [
    {
      display_name    = "Project Ownership Change Detected"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  ]

  user_labels = {
    purpose = "project-ownership-alerting"
  }
}
