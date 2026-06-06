/**
`google_network_connectivity_service_connection_policy` resource in Terraform is used to create and manage a Service Connection Policy (SCP) in Google Cloud's Network Connectivity Center.
This resource defines the policies governing service connections between a Virtual Private Cloud (VPC) and other Google Cloud services, providing rules on how service connections should be established and configured.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_connectivity_service_connection_policy
 */
resource "google_network_connectivity_service_connection_policy" "this" {
  for_each = var.policies

  network  = var.vpc_id
  location = var.gcp_region

  name          = "service-connection-policy-${each.key}"
  service_class = each.value.service_class
  description   = each.value.description

  psc_config {
    subnetworks = [var.subnet_id]
  }
}
