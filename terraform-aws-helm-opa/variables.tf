variable "namespace" {
  description = "The Namespace of the services."
  type        = string
  default     = "opa"
}
variable "helm_release_name" {
  description = "The Helm release of the services."
  type        = string
  default     = "opa"
}

variable "helm_chart_version" {
  default     = "0.1.13"
  type        = string
  description = "The chart version of OPA engine"
}

variable "opa_image_tag" {
  default     = "1.4.2"
  type        = string
  description = "The tag of the OPA docker image"
}

variable "create_namespace" {
  default     = true
  type        = bool
  description = "Create the namespace if it does not yet exist."
}
