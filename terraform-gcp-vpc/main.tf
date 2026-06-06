/**
`google_compute_network` provisions a VPC (Virtual Private Cloud) network resource on GCP.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
 */
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

/**
`google_compute_global_address` is used for HTTP(S) load balancing within VPC.
In other words, this resource is used for Private IP Peering.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
 */
resource "google_compute_global_address" "private_ip_peering" {
  name          = var.vpc_name
  description   = "A block of private IP addresses that are accessible only from within the VPC."
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.vpc.id
}

/**
`google_service_networking_connection` manages a private VPC connection with GCP Service Networking Connection.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection.html
 */
resource "google_service_networking_connection" "private_vpc_connection" {
  network = google_compute_network.vpc.id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.private_ip_peering.name
  ]
}

/**
`google_compute_subnetwork` provisions subnetworks (subnets) within a GCP VPC network.
A subnet is a partitioned IP range of a VPC network, allowing you to segregate and manage resources within specific IP address spaces.
This resource block creates subnetwork for Application.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
 */
resource "google_compute_subnetwork" "application" {
  name          = "${var.vpc_name}-application"
  ip_cidr_range = var.application_subnet_cidr
  network       = google_compute_network.vpc.id
  description   = "Subnetwork for web and application services"

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_subnet_cidr
  }

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_subnet_cidr
  }

  private_ip_google_access = true
}

/**
This resource block creates subnetwork for Data.
 */
resource "google_compute_subnetwork" "data" {
  name          = "${var.vpc_name}-data"
  ip_cidr_range = var.data_subnet_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  description   = "Subnetwork for data storage and processing"

  private_ip_google_access = true
}

/**
`google_compute_address` creates a regional static IP address.
The following resource is used to create IP address later for Cloud NAT (Network Address Translation).
NOTE:
- Recreating a google_compute_address that is being used by google_compute_router_nat will give a resourceInUseByAnotherResource error.
- Use lifecycle.create_before_destroy on this address resource to avoid this type of error as shown in the Manual Ips example.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address
 */
resource "google_compute_address" "nat_ip" {
  name   = var.nat_ip_address_name
  region = var.region

  lifecycle {
    create_before_destroy = true
  }
}

/**
`google_compute_router` is used to create and manage a Cloud Router in Google Cloud.
Cloud Routers enable dynamic routing within and between Virtual Private Cloud (VPC) networks,
supporting services like Cloud NAT, Hybrid Connectivity (e.g., VPN or Interconnect), and Dynamic Routing (BGP).
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
 */
resource "google_compute_router" "this" {
  name    = var.router_name
  region  = var.region
  network = google_compute_network.vpc.name

  bgp {
    asn                = var.router_asn
    keepalive_interval = var.router_keepalive_interval
  }
}

/**
`google_compute_router_nat` provisions a Cloud NAT service created in a router.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
 */
resource "google_compute_router_nat" "this" {
  name                                = var.nat_ip_address_name
  region                              = var.region
  router                              = google_compute_router.this.name
  nat_ip_allocate_option              = var.nat_ip_allocate_option
  nat_ips                             = google_compute_address.nat_ip.*.self_link
  source_subnetwork_ip_ranges_to_nat  = var.source_subnetwork_ip_ranges_to_nat
  min_ports_per_vm                    = var.min_ports_per_vm
  udp_idle_timeout_sec                = var.udp_idle_timeout_sec
  icmp_idle_timeout_sec               = var.icmp_idle_timeout_sec
  tcp_established_idle_timeout_sec    = var.tcp_established_idle_timeout_sec
  tcp_transitory_idle_timeout_sec     = var.tcp_transitory_idle_timeout_sec
  enable_endpoint_independent_mapping = var.enable_endpoint_independent_mapping

  dynamic "subnetwork" {
    for_each = var.subnetworks

    content {
      name                    = subnetwork.value.name
      source_ip_ranges_to_nat = subnetwork.value.source_ip_ranges_to_nat
    }
  }

  log_config {
    enable = var.log_config_enable
    filter = var.log_config_filter
  }
}
