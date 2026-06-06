variable "gke_ingress_services" {
  description = "The list of services to expose via GKE ingress."
  type = map(object({
    rate_limit = map(object({
      priority       = string # The priority of the rate limit rule.
      count          = string # The number of requests allowed within the specified interval.
      interval_sec   = string # The time interval in seconds for the rate limit rule.
      expression     = string # A CEL expression to match requests for applying the rate limit.
      preview        = bool   # Indicates whether the rate limit is in preview mode.
      enforce_on_key = string # The key on which the rate limit is enforced (e.g., "IP").
    }))
  }))
  default = {}
}

variable "project_id" {
  description = "The project ID to manage the resources."
  type        = string
}
