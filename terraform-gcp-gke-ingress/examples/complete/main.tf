module "gke_ingress" {
  source = "../../"

  project_id = "example-project"
  gke_ingress_services = {
    service-1 = {
      rate_limit = {
        limit_5_requests_per_hour_on_ip = {
          priority       = "1000"
          count          = "5"
          interval_sec   = "3600"
          expression     = "request.path.matches(\"/api/oauth/send-code\")"
          preview        = true
          enforce_on_key = "IP"
        }
      }
    },
    service-2 = {
      rate_limit = {
        limit_5_requests_per_hour_on_ip = {
          priority       = "1000"
          count          = "5"
          interval_sec   = "3600"
          expression     = "request.path.matches(\"/api/oauth/send-code\")"
          preview        = false
          enforce_on_key = "IP"
        }
      }
    }
  }
}
