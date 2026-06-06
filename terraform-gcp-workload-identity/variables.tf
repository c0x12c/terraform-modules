variable "pool_id" {
  description = "The workload identity pool id"
  type        = string
}

variable "project_id" {
  description = "The ID of the project in which the resource is created."
  type        = string
}

variable "service_account_id" {
  description = "The service account ID to bind to a workload identity pool IAM role."
  type        = string
}

variable "role" {
  description = "The role to be assigned to the service account."
  type        = string
}

variable "provider_list" {
  description = "A map of provider configurations used to manage resources for different services (e.g: GitHub, Jenkins)."
  type        = map(any)
  default     = {}
}

variable "create_identity_pool" {
  description = "Specifies whether to create a workload identity pool or use existing one."
  type        = bool
  default     = true
}
