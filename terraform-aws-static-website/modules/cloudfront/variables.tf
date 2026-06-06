variable "dns_name" {
  description = "The DNS name for the static website"
  type        = string
  default     = null
}

variable "domain_name" {
  description = "The domain name for the static website."
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 zone id"
  type        = string
}

variable "s3_bucket_id" {
  description = "The origin S3 bucket id"
  type        = string
}

variable "ssl_certificate_arn" {
  description = "SSL certificate arn for attaching to the Cloudfront distribution"
  type        = string
}

variable "viewer_protocol_policy" {
  description = "Determines the protocols that viewers can use to access your CloudFront distribution."
  type        = string
  default     = "redirect-to-https"
}

variable "minimum_protocol_version" {
  description = "The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections."
  type        = string
  default     = "TLSv1.2_2021"
}

variable "price_class" {
  description = "The price class for this distribution."
  type        = string
  default     = "PriceClass_100"
}

variable "use_www_domain" {
  description = "Use www domain"
  type        = bool
  default     = false
}

variable "use_wildcard_domain" {
  description = "Use wildcard domain"
  type        = bool
  default     = false
}

variable "distribution_aliases" {
  description = "List of domain names that associate with the CloudFront distribution."
  type        = list(string)
  default     = null
}

variable "ordered_cache_behaviors" {
  description = "List of ordered cache behaviors with path patterns and settings."
  type = list(object({
    path_pattern     = string
    allowed_methods  = list(string)
    cached_methods   = list(string)
    target_origin_id = string
    query_string     = bool
    cookies_forward  = string
    min_ttl          = number
    default_ttl      = number
    max_ttl          = number
    compress         = bool
    function_association = optional(object({
      event_type   = string
      function_arn = string
    }), null)
  }))
  default = []
}

variable "enabled_response_headers_policy" {
  description = "Enable response headers policy configuration"
  type        = bool
  default     = false
}

variable "referrer_policy" {
  description = "Referrer Policy settings"
  type = object({
    override        = bool
    referrer_policy = string
  })
  default = {
    override        = true
    referrer_policy = "strict-origin-when-cross-origin"
  }
}

variable "content_security_policy" {
  description = "Content Security Policy settings"
  type = object({
    override                = bool
    content_security_policy = string
  })
  default = {
    override                = true
    content_security_policy = "default-src 'self'; object-src 'none'; script-src 'self' 'strict-dynamic' https:; style-src 'self' 'unsafe-inline'; font-src 'self' https:; img-src 'self' https: data:; frame-ancestors 'none'; base-uri 'self'; form-action 'self';"
  }
}

variable "strict_transport_security" {
  description = "Strict Transport Security settings"
  type = object({
    override                   = bool
    access_control_max_age_sec = number
    include_subdomains         = bool
    preload                    = bool
  })
  default = {
    override                   = true
    access_control_max_age_sec = 63072000 # 2 years
    include_subdomains         = true
    preload                    = true
  }
}

variable "content_type_options" {
  description = "Content Type Options settings"
  type = object({
    override = bool
  })
  default = {
    override = true
  }
}

variable "wafv2_arn" {
  type        = string
  description = "Set the WAFv2 to enable Cloudfront and WAFv2 association"
  default     = null
}

variable "s3_redirect_domain" {
  description = "If set, configures the S3 bucket as a static website redirect to this domain."
  type        = string
  default     = null
}

variable "default_cache_behavior" {
  description = ""
  type = object({
    function_association = optional(object({
      event_type   = string
      function_arn = string
    }), null)
  })
  default = {}
}
