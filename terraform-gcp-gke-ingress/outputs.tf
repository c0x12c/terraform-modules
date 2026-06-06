output "gke_ingress_lb_ip" {
  description = "A mapping of the service names to their corresponding Load Balancer IP addresses in the GKE cluster."
  value       = local.service_ip_mapping
}

output "gke_ingress_throttle_policy_name" {
  description = "A mapping of the service names to their associated throttle policy names."
  value       = local.policy_mapping
}
