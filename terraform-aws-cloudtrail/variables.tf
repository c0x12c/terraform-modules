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
