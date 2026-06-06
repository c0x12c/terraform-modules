/**
Please navigate to README.md if you failed SOC2 on this resource
 */
module "vpc_network_change_alert" {
  source = "../../google-monitoring"

  name        = "vpc-network-change-metric"
  description = "Detects VPC network changes"
  filter      = <<EOT
resource.type="gce_network"
AND (
  protoPayload.methodName="beta.compute.networks.insert"
  OR protoPayload.methodName="beta.compute.networks.patch"
  OR protoPayload.methodName="v1.compute.networks.delete"
  OR protoPayload.methodName="v1.compute.networks.removePeering"
  OR protoPayload.methodName="v1.compute.networks.addPeering"
)
EOT

  resource_type = "gce_network"

  metric_kind = "DELTA"
  value_type  = "INT64"
  unit        = "1"

  combiner = "OR"

  conditions = [
    {
      display_name    = "VPC Network Change Detected"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  ]

  user_labels = {
    purpose = "vpc-alerting"
  }
}

module "vpc_network_route_change_alert" {
  source = "../../google-monitoring"

  name          = "vpc-network-route-change-metric"
  description   = "Detects VPC route changes"
  filter        = <<EOT
resource.type="gce_route"
AND (
  protoPayload.methodName="beta.compute.routes.patch"
  OR protoPayload.methodName="beta.compute.routes.insert"
)
EOT
  resource_type = "global"

  metric_kind = "DELTA"
  value_type  = "INT64"
  unit        = "1"

  combiner = "OR"

  conditions = [
    {
      display_name    = "VPC Route Change Detected"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "60s"
    }
  ]

  user_labels = {
    purpose = "vpc-route-alerting"
  }
}
