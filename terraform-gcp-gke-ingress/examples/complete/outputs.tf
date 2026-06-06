output "service_1_gke_ingress_lb_ip_address" {
  value = module.gke_ingress.gke_ingress_lb_ip["service-1"].address
}

output "service_2_gke_ingress_lb_ip_address" {
  value = module.gke_ingress.gke_ingress_lb_ip["service-2"].address
}

output "service_1_gke_ingress_lb_ip_name" {
  value = module.gke_ingress.gke_ingress_lb_ip["service-1"].name
}

output "service_2_gke_ingress_lb_ip_name" {
  value = module.gke_ingress.gke_ingress_lb_ip["service-2"].name
}

output "service_1_gke_ingress_throttle_policy_name" {
  value = module.gke_ingress.gke_ingress_throttle_policy_name["service-1"]
}

output "service_2_gke_ingress_throttle_policy_name" {
  value = module.gke_ingress.gke_ingress_throttle_policy_name["service-2"]
}
