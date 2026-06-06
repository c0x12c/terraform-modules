variable "team_id" {
  description = "The ID of the Datadog team to associate with the on-call resources."
  type        = string
}
variable "urgency" {
  description = "The urgency level for the routing rule."
  type        = string
  default     = "high"
  validation {
    condition     = contains(["low", "dynamic", "high"], var.urgency)
    error_message = "Urgency must be one of 'low', 'dynamic', or 'high'."
  }
}
variable "schedule" {
  description = "Configuration for the on-call schedule, including name, time zone, and layer details."
  type = object({
    name      = string
    time_zone = string
    layer = object({
      name           = string
      effective_date = string
      rotation_start = string
      interval_days  = number
      users          = list(string)
    })
  })
}
variable "escalation_policy" {
  description = "Configuration for the on-call escalation policy."
  type = object({
    name                       = string
    resolve_page_on_policy_end = bool
    retries                    = number
  })
}
variable "escalation_policy_escalate_after_seconds" {
  description = "The number of seconds after which to escalate the on-call notification."
  type        = number
  default     = 60
}