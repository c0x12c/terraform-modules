variable "service_account_id" {
  description = "The account ID that is used to generate service account email address and a stable unique id."
  type        = string
  validation {
    condition     = length(var.service_account_id) >= 6 && length(var.service_account_id) <= 30 && can(regex("[a-z]([-a-z0-9]*[a-z0-9])", var.service_account_id))
    error_message = "The value must be 6-30 characters long, and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])"
  }
}

variable "service_account_display_name" {
  description = "The display name for the service bot service account."
  type        = string
  default     = null
}

variable "description" {
  description = "A text description of the service bot service account. Must be less than or equal to 256 UTF-8 bytes."
  type        = string
  default     = null
}

variable "disabled_service_account" {
  description = "Whether the service account is disabled or not."
  type        = string
  default     = false
}

variable "permissions" {
  description = "A list of permissions granted to service account."
  type        = list(string)
  default     = []
}

variable "roles" {
  description = "A list of roles granted to service account."
  type        = list(string)
  default     = []
}

variable "enabled_create_custom_role" {
  description = "Whether to create a custom role or not."
  type        = bool
  default     = false
}
