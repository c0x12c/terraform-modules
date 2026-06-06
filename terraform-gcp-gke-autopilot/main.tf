/**
`google_container_cluster` resource provisions a GKE Autopilot cluster.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
*/
resource "google_container_cluster" "autopilot_gke" {
  provider = google-beta

  name                = var.cluster_name
  project             = var.project_id
  location            = var.region
  network             = var.network
  subnetwork          = var.subnetwork
  deletion_protection = var.deletion_protection
  min_master_version  = var.min_master_version
  enable_autopilot    = true
  resource_labels     = var.labels

  release_channel {
    channel = var.release_channel
  }

  private_cluster_config {
    enable_private_endpoint = var.enable_private_endpoint
    enable_private_nodes    = var.enable_private_nodes
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config != null && length(var.master_authorized_networks_config) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks_config
        content {
          cidr_block   = lookup(cidr_blocks.value, "cidr_block", "")
          display_name = lookup(cidr_blocks.value, "display_name", "")
        }
      }
    }
  }

  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_start_time
      end_time   = var.maintenance_end_time
      recurrence = var.maintenance_recurrence
    }
  }

  vertical_pod_autoscaling {
    enabled = var.enable_vertical_pod_autoscaling
  }

  cost_management_config {
    enabled = var.enable_cost_management_config
  }

  cluster_telemetry {
    type = "ENABLED"
  }
}
