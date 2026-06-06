variable "create_new" {
  description = "Flag to determine if new resources should be created"
  type        = bool
  default     = false
}

variable "dns_zone" {
  description = "The DNS zone name for Route 53 configuration"
  type        = string
}

variable "custom_records" {
  description = "Custom DNS records for Route 53 configuration, with options for type, TTL, and record values"
  type = map(object({
    zone_id = optional(string)
    type    = optional(string) // default: CNAME
    ttl     = optional(number) // default: 3600
    records = list(string)
  }))
  default = {}
}
