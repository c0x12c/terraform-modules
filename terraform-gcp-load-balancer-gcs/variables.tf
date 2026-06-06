variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "prefix_name" {
  description = "Prefix for all resources created by this module."
  type        = string
}

variable "enable_http" {
  description = "If true, enable HTTP for this BackendBucket."
  type        = bool
  default     = true
}

variable "enable_ssl" {
  description = "If true, enable SSL for this BackendBucket."
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "Name of Backend bucket."
  type        = string
  default     = null
}

variable "enable_cdn" {
  description = "If true, enable Cloud CDN for this BackendBucket."
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Domains for which a managed SSL certificate will be valid."
  type        = string
  default     = null
}

variable "certificate_map" {
  description = "Certificate map to use for the load balancer."
  type        = string
  default     = null
}