output "application_subnetwork_id" {
  description = "The ID of the application subnetwork."
  value       = google_compute_subnetwork.application.id
}

output "application_subnetwork_name" {
  description = "The name of the application subnetwork."
  value       = google_compute_subnetwork.application.name
}

output "data_subnetwork_id" {
  description = "The ID of the data subnetwork."
  value       = google_compute_subnetwork.data.id
}

output "data_subnetwork_name" {
  description = "The name of the data subnetwork."
  value       = google_compute_subnetwork.data.name
}

output "vpc_network_id" {
  description = "The ID of the VPC network."
  value       = google_compute_network.vpc.id
}

output "vpc_network_name" {
  description = "The name of the VPC network."
  value       = google_compute_network.vpc.name
}

output "services_secondary_range_name" {
  description = "The name of the application subnetwork's secondary_ip_range range name: services."
  value       = google_compute_subnetwork.application.secondary_ip_range[0].range_name
}

output "pods_secondary_range_name" {
  description = "The name of the application subnetwork's secondary_ip_range range name: pods."
  value       = google_compute_subnetwork.application.secondary_ip_range[1].range_name
}

output "cloud_router" {
  description = "A reference (self_link) to the Cloud Router."
  value       = google_compute_router.this.self_link
}

output "cloud_nat_id" {
  description = "A full resource identifier of the Cloud NAT."
  value       = google_compute_router_nat.this.id
}

output "google_compute_address" {
  description = "A reference (self_link) to the Google Compute Address."
  value       = google_compute_address.nat_ip.*.self_link
}
