output "application_subnetwork_id" {
  value = module.vpc.application_subnetwork_id
}

output "application_subnetwork_name" {
  value = module.vpc.application_subnetwork_name
}

output "data_subnetwork_id" {
  value = module.vpc.data_subnetwork_id
}

output "data_subnetwork_name" {
  value = module.vpc.data_subnetwork_name
}

output "vpc_network_id" {
  value = module.vpc.vpc_network_id
}

output "vpc_network_name" {
  value = module.vpc.vpc_network_name
}

output "services_secondary_range_name" {
  value = module.vpc.services_secondary_range_name
}

output "pods_secondary_range_name" {
  value = module.vpc.pods_secondary_range_name
}

output "cloud_router" {
  value = module.vpc.cloud_router
}

output "cloud_nat_id" {
  value = module.vpc.cloud_nat_id
}

output "google_compute_address" {
  value = module.vpc.google_compute_address
}
