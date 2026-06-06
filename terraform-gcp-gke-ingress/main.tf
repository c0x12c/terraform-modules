/**
`google_compute_global_address` manages global addresses are used for HTTP(S) load balancing.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
 */
resource "google_compute_global_address" "this" {
  for_each     = var.gke_ingress_services
  name         = "${each.key}-public-ip-address"
  project      = var.project_id
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

/**
`google_compute_security_policy` defines an IP blacklist or whitelist that protects load balanced Google Cloud services by denying or permitting traffic from specified IP ranges.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_security_policy
 */
resource "google_compute_security_policy" "throttle" {
  for_each = var.gke_ingress_services

  name        = "${each.key}-gke-ingress-throttle-policy"
  description = "Rate limits policy for gke ingress for ${each.key}"

  dynamic "rule" {
    for_each = each.value.rate_limit

    content {
      action   = "throttle"
      preview  = rule.value["preview"]
      priority = rule.value["priority"]

      rate_limit_options {
        conform_action = "allow"
        exceed_action  = "deny(429)"
        enforce_on_key = contains(keys(rule.value), "enforce_on_key") ? rule.value["enforce_on_key"] : "ALL"

        rate_limit_threshold {
          count        = rule.value["count"]
          interval_sec = rule.value["interval_sec"]
        }
      }

      match {
        expr {
          expression = rule.value["expression"] // expression should be a single string only
        }
      }
      description = "Rate limit rule."
    }
  }

  rule {
    action      = "allow"
    priority    = "2147483647"
    description = "Default rule."

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}
