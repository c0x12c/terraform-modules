variable "bucket_name" {
  description = "The bucket name to be created."
  type        = string
  default     = null
}

variable "bucket_prefix" {
  description = "The bucket prefix to be created."
  type        = string
  default     = null
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced"
  type        = string
  default     = null
}

variable "enabled_cors" {
  description = "Enable to configure the CORS"
  type        = bool
  default     = false
}

variable "cors_configuration" {
  description = "Configuration for CORS settings"
  type = object({
    allowed_headers = optional(list(string))
    expose_headers  = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    max_age_seconds = optional(number)
  })
  default = {
    allowed_headers = []
    expose_headers  = []
    allowed_methods = []
    allowed_origins = []
    max_age_seconds = 3600
  }
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "enabled_public_policy" {
  description = "Enabled create the Public Policy to allow public access to bucket objects."
  type        = bool
  default     = false
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

variable "versioning_status" {
  description = "The status of bucket versioning."
  type        = string
  default     = "Disabled"
}

variable "server_side_encryption" {
  description = "Server-side encryption configuration. Null (default) creates no encryption resource, leaving the S3 account default in place."
  type = object({
    sse_algorithm      = string
    kms_master_key_id  = optional(string)
    bucket_key_enabled = optional(bool, true)
  })
  default = null

  validation {
    condition = var.server_side_encryption == null || contains(
      ["AES256", "aws:kms"],
      var.server_side_encryption.sse_algorithm,
    )
    error_message = "server_side_encryption.sse_algorithm must be one of AES256 or aws:kms."
  }

  validation {
    condition = var.server_side_encryption == null || (
      var.server_side_encryption.sse_algorithm != "aws:kms" ||
      try(var.server_side_encryption.kms_master_key_id, null) != null
    )
    error_message = "server_side_encryption.kms_master_key_id must be set when sse_algorithm is aws:kms."
  }
}

variable "object_lock_enabled" {
  description = "Enable S3 Object Lock. CREATION-TIME ONLY - toggling this on an existing bucket forces replacement. Requires versioning_status = \"Enabled\"."
  type        = bool
  default     = false
}

variable "object_lock_default_retention" {
  description = "Default retention rule applied to new objects. Null means Object Lock is enabled with no default rule (per-object retention only)."
  type = object({
    mode  = string
    days  = optional(number)
    years = optional(number)
  })
  default = null

  validation {
    condition = var.object_lock_default_retention == null || contains(
      ["GOVERNANCE", "COMPLIANCE"],
      var.object_lock_default_retention.mode,
    )
    error_message = "object_lock_default_retention.mode must be one of GOVERNANCE or COMPLIANCE."
  }

  validation {
    condition = var.object_lock_default_retention == null || (
      (try(var.object_lock_default_retention.days, null) != null) !=
      (try(var.object_lock_default_retention.years, null) != null)
    )
    error_message = "object_lock_default_retention must set exactly one of days or years."
  }
}

variable "enabled_iam_policy" {
  description = "Enabled create the IAM Policies."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Enable to force destroy the bucket."
  type        = bool
  default     = false
}

variable "acl" {
  description = "Canned ACL to apply to the bucket. Support private and public-read."
  type        = string
  default     = "private"
}

variable "read_write_actions" {
  description = "Read write policy actions"
  type        = list(string)
  default = [
    "s3:DeleteObject",
    "s3:GetObject",
    "s3:GetObjectAcl",
    "s3:ListBucket",
    "s3:ObjectOwnerOverrideToBucketOwner",
    "s3:PutObject",
    "s3:PutObjectAcl"
  ]
}

# avoid recreating policies and their dependent resources during migration
variable "read_write_policy_description" {
  description = "Description for read write policy"
  type        = string
  default     = "Policy that allows writing to the S3 bucket"
}

variable "read_write_policy_name_prefix" {
  description = "The name prefix for the read write policy"
  type        = string
  default     = "S3ReadWrite"
}

variable "readonly_policy_description" {
  description = "Description for readonly policy"
  type        = string
  default     = "Policy that allows reading from the s3 assets bucket"
}

variable "readonly_policy_name_prefix" {
  description = "The name prefix for the readonly policy"
  type        = string
  default     = "S3AssetsRead"
}

variable "public_policy_description" {
  description = "Description for public policy"
  type        = string
  default     = "Policy that allows writing to the s3 public assets bucket"
}

variable "public_policy_name_prefix" {
  description = "The name prefix for the public policy"
  type        = string
  default     = "S3PublicAssetsWrite"
}

# Custom name

variable "custom_readonly_policy_name" {
  description = "The custom read only policy name to overwrite default one"
  type        = string
  default     = null
}

variable "custom_read_write_policy_name" {
  description = "The custom read write policy name to overwrite default one"
  type        = string
  default     = null
}

variable "access_log_target_prefix" {
  description = "The target prefix for the access logs"
  type        = string
  default     = null
}

variable "access_log_target_bucket_id" {
  description = "The bucket ID to store the access logs"
  type        = string
  default     = null
}

variable "write_access_logs_source_bucket_arns" {
  description = "If specified, the bucket will have a policy that allows the specified source buckets to write access logs to it."
  type        = list(string)
  default     = []
}

variable "disabled_s3_http_access" {
  description = "Whether to restrict HTTP access to S3 bucket."
  type        = bool
  default     = true
}

variable "create_bucket_policy" {
  description = "Whether to create bucket policy."
  type        = bool
  default     = true
}

# lifecycle config
variable "s3_lifecycle_rules" {
  description = "List of S3 bucket lifecycle configuration."
  type = list(object({
    id              = string
    status          = string               # "Enabled" or "Disabled"
    filter_prefix   = optional(string, "") # "" will apply to all
    transition_days = optional(number, 0)
    expiration_days = number
    storage_class   = string # "STANDARD_IA", "DEEP_ARCHIVE", "GLACIER", ...
  }))
  default = null
}

variable "custom_bucket_policy" {
  description = "DEPRECATED: use `custom_bucket_policies` instead. Single custom bucket policy statement."
  type = object({
    sid       = string
    effect    = string
    actions   = list(string)
    resources = optional(list(string))
    principals = optional(object({
      type        = string
      identifiers = list(string)
    }))
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  })
  default = null
}

variable "custom_bucket_policies" {
  description = "List of custom bucket policy statements appended to the bucket policy document. Each entry follows the aws_iam_policy_document statement shape."
  type = list(object({
    sid       = string
    effect    = string
    actions   = list(string)
    resources = optional(list(string))
    principals = optional(object({
      type        = string
      identifiers = list(string)
    }))
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = null
}

# access logging
variable "access_logs_bucket_arn" {
  description = "The arn of bucket that stores access logs"
  type        = string
  default     = null
}
