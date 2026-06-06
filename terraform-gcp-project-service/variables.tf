variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "services" {
  description = "A list of services to enable."
  type        = list(string)
}

variable "disable_on_destroy" {
  description = "If `true` or unset, disable the service when the Terraform resource is destroyed. If `false`, the service will be left enabled when the Terraform resource is destroyed."
  type        = bool
  default     = false
}
