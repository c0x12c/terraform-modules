output "ip_address" {
  value = google_compute_global_address.this.address
}

output "lb_name" {
  value = google_compute_url_map.bucket.name
}