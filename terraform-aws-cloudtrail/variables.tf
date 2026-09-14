variable "name" {
  type        = string
  description = "A friendly name of the CloudTrail."
}

variable "enable_log_file_validation" {
  type        = bool
  description = "Specifies whether log file integrity validation is enabled. Creates signed digest for validated contents of logs"
  default     = false
}

variable "is_multi_region_trail" {
  type        = bool
  description = "Specifies whether the trail is created in the current region or in all regions"
  default     = false
}

variable "include_global_service_events" {
  type        = bool
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files"
  default     = false
}

variable "enable_logging" {
  type        = bool
  description = "Enable logging for the trail"
  default     = false
}

variable "insight_selector" {
  type = list(object({
    insight_type = string
  }))

  description = "Specifies an insight selector for type of insights to log on a trail"
  default     = []
}

variable "event_selector" {
  type = list(object({
    include_management_events = bool
    read_write_type           = string

    data_resource = list(object({
      type   = string
      values = list(string)
    }))
  }))

  description = "Specifies an event selector for enabling data event logging. See: https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for details on this variable"
  default     = []
}

variable "kms_key_arn" {
  type        = string
  description = "Specifies the KMS key ARN to use to encrypt the logs delivered by CloudTrail"
  default     = null
}

variable "is_organization_trail" {
  type        = bool
  default     = false
  description = "The trail is an AWS Organizations trail"
}

variable "sns_topic_name" {
  type        = string
  description = "Specifies the name of the Amazon SNS topic defined for notification of log file delivery"
  default     = null
}

variable "s3_key_prefix" {
  type        = string
  description = "Prefix for S3 bucket used by Cloudtrail to store logs"
  default     = null
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

variable "versioning_status" {
  description = "The status of bucket versioning."
  type        = string
  default     = "Disabled"
}

variable "disabled_s3_http_access" {
  description = "Whether to restrict HTTP access to S3 bucket."
  type        = bool
  default     = true
}

# cloudwatch integration

variable "cloud_watch_logs_role_arn" {
  type        = string
  description = "Specifies the role for the CloudWatch Logs endpoint to assume to write to a user’s log group"
  default     = null
}

variable "cloud_watch_logs_group_arn" {
  type        = string
  description = "Specifies a log group name using an Amazon Resource Name (ARN), that represents the log group to which CloudTrail logs will be delivered"
  default     = null
}

variable "create_cloudwatch_log_group" {
  description = "Whether to create CloudWatch log group to deliver CloudTrail logs to."
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  type = list(object({
    id     = string
    status = optional(string, "Enabled")

    # Applies to every object in the bucket when omitted.
    prefix = optional(string)

    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])

    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
    abort_incomplete_mpu_days          = optional(number)
  }))

  description = "Lifecycle rules for the log bucket. Empty (the default) creates no lifecycle configuration at all, because a lifecycle configuration with zero rules is rejected by the provider."
  default     = []

  # Every action field is optional, so the type alone admits a rule that does nothing. The provider
  # rejects such a rule at apply with a message that does not name the rule, so catch it here.
  validation {
    condition = alltrue([
      for r in var.lifecycle_rules :
      length(r.transitions) > 0 ||
      r.expiration_days != null ||
      r.noncurrent_version_expiration_days != null ||
      r.abort_incomplete_mpu_days != null
    ])
    error_message = "Each lifecycle rule needs at least one action: transitions, expiration_days, noncurrent_version_expiration_days or abort_incomplete_mpu_days."
  }
}

variable "transition_default_minimum_object_size" {
  type        = string
  description = "Minimum object size S3 applies to lifecycle transitions: all_storage_classes_128K, or varies_by_storage_class to apply the 128 KB floor to Standard-IA and Intelligent-Tiering only. CloudTrail writes small gzipped objects, so the 128 KB default silently no-ops a Glacier transition."
  default     = "varies_by_storage_class"

  validation {
    condition     = contains(["all_storage_classes_128K", "varies_by_storage_class"], var.transition_default_minimum_object_size)
    error_message = "Must be all_storage_classes_128K or varies_by_storage_class."
  }
}
