variable "name" {
  description = "The service name that is used to name the associating configmap, secret and service account."
  type        = string
}

variable "environment" {
  description = "The environment to create associating resources."
  type        = string
}

variable "namespace" {
  description = "The namespace to create k8s secrets and configmap."
  type        = string
}

variable "config_map" {
  description = "The map of configmap."
  type        = map(any)
  default     = {}
}

variable "secrets" {
  description = "The map of secrets."
  type        = map(any)
  default     = {}
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

variable "hostname" {
  description = "The hostname or subdomain name to create DNS record for associating service. Should be non-nullable if `managed_zone` differentiates from `null`."
  type        = string
  default     = null
}

variable "domain_name" {
  description = "The domain name. Should be non-nullable if `managed_zone` differentiates from `null`."
  type        = string
  default     = null
}

variable "managed_zone" {
  description = "The GCP zone name associating with `domain_name`. If set to `null`, no DNS records are created."
  type        = string
  default     = null
}

variable "dns_ttl" {
  description = "The DNS record TTL (Time To Live) time in seconds."
  type        = number
  default     = 300
}

variable "dns_rrdatas" {
  description = "The DNS record `rrdatas` refers to the data associated with a DNS record, allowing for the correct mapping and routing of network traffic based on DNS resolution."
  type        = list(string)
  default     = []
}

variable "create_namespace" {
  description = "Specifies whether to create a namespace. If set to `false`, it will create resources using existing `namespace`."
  type        = bool
  default     = true
}

variable "create_dns_zone" {
  description = "Specifies whether to create DNS zone. If set to `false`, it will create DNS records using existing `managed_zone`."
  type        = bool
  default     = false
}

variable "create_custom_role" {
  description = "Whether to create a custom role or not. If set to `true`, it will grant `roles` to service account, else, it will create custom role with `permissions`."
  type        = bool
  default     = false
}
