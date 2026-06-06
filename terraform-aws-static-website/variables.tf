variable "dns_name" {
  description = "The DNS name for the static website"
  type        = string
  default     = null
}

variable "domain_name" {
  description = "The domain name for the static website."
  type        = string
}

variable "enabled_create_s3" {
  description = "The bool value determining whether to create a new S3 bucket"
  type        = bool
}

variable "existing_s3_bucket_name" {
  description = "The name of the existing S3 bucket to use"
  type        = string
  default     = null
}

variable "global_tls_certificate_arn" {
  description = "The TLS certificate arn for the root domain name"
  type        = string
}

variable "name" {
  description = "For creating or retrieving the bucket and cloudfront name"
  type        = string
}

variable "route53_zone_id" {
  description = "R53 zone ID"
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

variable "enabled_read_write_policy" {
  description = "Enabled create the Read Write Policy to allow access to bucket objects."
  type        = bool
  default     = false
}

variable "enabled_read_only_policy" {
  description = "Enabled create the Read Only Policy to allow access to bucket objects."
  type        = bool
  default     = false
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

variable "cloudfront_distribution_aliases" {
  description = "List of domain names that is associated with the CloudFront distribution."
  type        = list(string)
  default     = null
}

variable "versioning_status" {
  description = "Whether to enable versioning on S3 bucket."
  type        = string
  default     = "Disabled"

  validation {
    condition     = var.versioning_status == "Disabled" || var.versioning_status == "Enabled"
    error_message = "Only `Disabled` or `Enabled` are valid."
  }
}

# avoid recreating policies and their dependent resources during migration
variable "s3_read_write_policy_description" {
  description = "Description for read write policy"
  type        = string
  default     = "Policy that allows writing to the S3 bucket"
}

variable "s3_readonly_policy_description" {
  description = "Description for readonly policy"
  type        = string
  default     = "Policy that allows reading from the s3 assets bucket"
}

# Custom name
variable "bucket_prefix" {
  description = "Overwrite bucket prefix name."
  type        = string
  default     = null
}

variable "s3_custom_readonly_policy_name" {
  description = "The custom read only policy name to overwrite default one"
  type        = string
  default     = null
}

variable "s3_custom_read_write_policy_name" {
  description = "The custom read write policy name to overwrite default one"
  type        = string
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
  description = "Enable response headers policy configuration."
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

# access logging
variable "access_logs_bucket_arn" {
  description = "The arn of bucket that stores access logs"
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
