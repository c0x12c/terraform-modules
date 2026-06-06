locals {
  service_ip_mapping = {
    for service, service_config in var.gke_ingress_services :
    service => {
      name    = google_compute_global_address.this[service].name
      address = google_compute_global_address.this[service].address
    }
  }

  policy_mapping = {
    for service, service_config in var.gke_ingress_services :
    service => google_compute_security_policy.throttle[service].name
  }
}
