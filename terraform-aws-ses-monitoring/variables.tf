variable "name" {
  description = "The name of the outgoing logs"
  type        = string
}

variable "environment" {
  description = "The environment of the outgoing logs"
  type        = string
}

variable "ses_identity_ids" {
  description = "Map of SES identity IDs"
  type        = map(string)
  # Example: { "email1" = "identity1", "email2" = "identity2" }
}

variable "datadog_api_key" {
  description = "The datadog api key"
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "The datadog site"
  type        = string
  default     = "datadoghq.com"
}

variable "enabled_outgoing_email_logs_cloudwatch" {
  description = "Whether to enable the SES outgoing email logs on CloudWatch."
  type        = bool
  default     = false
}

variable "enabled_datadog_dashboard" {
  description = "Whether to enable the Datadog dashboard."
  type        = bool
  default     = false
}

variable "datadog_dashboard_environments" {
  description = "The environments to enable the Datadog dashboard for."
  type        = list(string)
  default     = ["dev", "prod"]
}

variable "datadog_dashboard_default_environment" {
  description = "The default environments to enable the Datadog dashboard for."
  type        = string
  default     = "prod"
}
