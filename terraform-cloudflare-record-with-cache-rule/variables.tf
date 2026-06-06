variable "zone_id" {
  description = "The ID of the Cloudflare zone where the DNS record will be created."
  type        = string
}

variable "comment" {
  description = "Optional comment for the DNS record."
  type        = string
  default     = null
}

variable "name" {
  description = "The name of the DNS record, such as 'example.com'."
  type        = string
}

variable "enabled_proxy" {
  description = "Whether the record is proxied through Cloudflare."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for the DNS record."
  type        = list(string)
  default     = []
}

variable "ttl" {
  description = "Time to live for the DNS record."
  type        = number
  default     = 1
}

variable "type" {
  description = "The type of DNS record (e.g., A, CNAME)."
  type        = string
  default     = "A"
}

variable "settings" {
  description = "Optional settings for the DNS record."
  type        = map(any)
  default = {
    ipv4_only = false
    ipv6_only = false
  }
}

variable "cache_status" {
  description = "The status of the page rule for caching."
  type        = string
  default     = "active"
}

variable "page_rule_actions" {
  description = "Actions for the page rule associated with the DNS record."
  type        = map(any)
  default = {
    cache_level       = "cache_everything"
    edge_cache_ttl    = 86400
    browser_cache_ttl = 86400
  }
}

variable "record_content" {
  description = "The content of the DNS record, such as an IP address or CNAME target."
  type        = string
}