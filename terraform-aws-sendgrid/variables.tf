# General variables

variable "dns_zone_name" {
  description = "The name of the DNS zone to be used for SendGrid configuration."
  type        = string
}

variable "dns_zone_id" {
  description = "The unique identifier of the DNS zone."
  type        = string
}

# SendGrid variables

variable "api_keys" {
  description = "A map of API keys with their names and associated scopes. Scopes define the permissions granted to each API key."
  type = map(object({
    name   = string
    scopes = list(string) # https://docs.sendgrid.com/api-reference/api-key-permissions/api-key-permissions
  }))
}

variable "automatic_security" {
  description = "Whether to allow SendGrid to manage SPF records, DKIM keys, and DKIM key rotation automatically."
  type        = bool
  default     = true
}

variable "is_default_authenticated_domain" {
  description = "Whether to use this authenticated domain as the fallback if no authenticated domains match the sender's domain."
  type        = bool
  default     = true
}

variable "is_default_link_branding" {
  description = "Indicates if this is the default link branding."
  type        = bool
  default     = true
}

variable "sendgrid_transactional_templates" {
  description = "A map of SendGrid transactional email templates, each containing a subject and content."
  type = map(object({
    subject = string
    content = string
  }))
  default = {}
}
