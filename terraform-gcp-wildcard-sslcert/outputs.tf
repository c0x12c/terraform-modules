output "cert_map" {
  description = "The name of the Google Certificate Manager certificate map for wildcard domains."
  value       = google_certificate_manager_certificate_map.wildcard_map.name
}

