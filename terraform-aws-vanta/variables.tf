variable "vanta_aws_account_id" {
  type        = string
  default     = "956993596390"
  description = "The ID of the Vanta role used for managing access and permissions in the environment."
}

variable "policy_name" {
  type        = string
  default     = "VantaAdditionalPermissions"
  description = "The name of the IAM policy created to provide additional permissions required by Vanta."
}

variable "role_name" {
  type        = string
  default     = "vanta-auditor"
  description = "The name of the IAM role created for Vanta to use for auditing and monitoring purposes."
}

variable "vanta_scanner_external_id" {
  type        = string
  description = "The external ID used by Vanta to verify the trust relationship with the Vanta role."
}
