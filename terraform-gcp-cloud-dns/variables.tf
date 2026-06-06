variable "create_new" {
  description = "Flag to determine if new resources should be created."
  type        = bool
  default     = false
}

variable "dns_zone" {
  description = "A DNS zone is a DNS namespace used to manage DNS records for a domain."
  type        = string
}

variable "dns_name" {
  description = "The DNS name of a DNS managed zone."
  type        = string
}

variable "description" {
  description = "The user-provided description of the DNS zone."
  type        = string
  default     = ""
}

variable "visibility" {
  description = "The DNS zone visibility: where public zones are exposed to the Internet, while private zones are visible only to Virtual Private Cloud resources. Possible values are: private, public."
  type        = string
  default     = "public"
  validation {
    condition     = var.visibility == "public" || var.visibility == "private"
    error_message = "The supported keys are public, private"
  }
}

variable "custom_records" {
  description = "Custom DNS records within Google Cloud DNS."
  type = map(object({
    type    = optional(string) // default: CNAME
    ttl     = optional(number) // default: 3600
    rrdatas = list(string)
  }))
  default = {}
}
