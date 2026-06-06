variable "environment" {
  description = "Environment where the resources will be created."
  type        = string
}

variable "bucket_name" {
  description = "The name of the google bucket being created."
  type        = string
}

variable "bucket_name_overwrite" {
  description = "The overwrite name of the google bucket being created."
  type        = string
  default     = null
}

variable "location" {
  description = "The Google Cloud Storage Service location."
  type        = string
  default     = "US"
}

variable "force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects."
  type        = bool
  default     = false
}

variable "storage_class" {
  description = "The Storage Class of the new bucket. Supported values include: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE."
  type        = string
  default     = "STANDARD"
}

variable "uniform_bucket_level_access" {
  description = "Enables Uniform bucket-level access access to a bucket."
  type        = bool
  default     = false
}

variable "public_access_prevention" {
  description = "Prevents public access to a bucket. Acceptable values are inherited or enforced."
  type        = string
  default     = "inherited"
}

variable "is_public" {
  description = "Allow public access to a bucket"
  type        = bool
  default     = false
}

variable "is_listable" {
  description = "Allow list object in a bucket"
  type        = bool
  default     = false
}

variable "is_static_web" {
  description = "Set the bucket as static web"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "While set to true, versioning is fully enabled for this bucket."
  type        = bool
  default     = false
}

variable "main_page_suffix" {
  description = "Behaves as the bucket's directory index where missing objects are treated as potential directories."
  type        = string
  default     = "index.html"
}

variable "not_found_page" {
  description = "The custom object to return when a requested resource is not found."
  type        = string
  default     = "404.html"
}

variable "enable_cors" {
  description = "Enable the bucket's Cross-Origin Resource Sharing (CORS) configuration."
  type        = bool
  default     = false
}

variable "cors_origins" {
  description = "The list of Origins eligible to receive CORS response headers."
  type        = list(string)
  default     = []
}

variable "cors_methods" {
  description = "The list of HTTP methods on which to include CORS response headers."
  type        = list(string)
  default     = []
}

variable "cors_extra_headers" {
  description = "The list of HTTP headers other than the simple response headers to give permission for the user-agent to share across domains."
  type        = list(string)
  default     = []
}

variable "cors_max_age_seconds" {
  description = "The value, in seconds, to return in the Access-Control-Max-Age header used in preflight responses."
  type        = number
  default     = 600
}

variable "bucket_users" {
  description = "A list of users who will have write access to the specified storage bucket."
  default     = []
}

variable "bucket_viewers" {
  description = "A list of users who will have read-only access to the specified storage bucket."
  default     = []
}

variable "soft_delete_policy" {
  description = "Optional soft delete policy"
  type = object({
    retention_duration_seconds = number
  })
  default = null
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
  type = list(object({
    age                        = number // days
    type                       = string // action type
    days_since_noncurrent_time = number // days
  }))
  default = []
}

variable "enable_logging" {
  description = "Whether to enable logging"
  type        = bool
  default     = false
}

/**
access logs
 */
variable "enable_creator_policy" {
  description = "Whether to allow bucket create objects on itself. Should be enabled if you use this as log bucket."
  type        = bool
  default     = false
}

variable "logging" {
  description = "Define this block whether to enable logging"
  type = object({
    enabled            = bool
    destination_bucket = string
  })
  default = null
}
