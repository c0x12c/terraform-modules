variable "domain" {
  description = "The domain name to be managed, such as example.com."
  type        = string
}

variable "managed_zone" {
  description = "The name of the managed DNS zone in Google Cloud. Defaults to null, meaning no managed zone is specified."
  type        = string
  default     = null
}

variable "dns_record_set_ttl" {
  description = "The Time To Live (TTL) for DNS record sets, specified in seconds. Defaults to 300 seconds (5 minutes)."
  type        = number
  default     = 300
}
