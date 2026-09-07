variable "create" {
  description = "Determines whether to create the DataSync task and its supporting resources."
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the DataSync task, and base name for the IAM role, locations, and log group."
  type        = string
}

variable "source_bucket_arn" {
  description = "ARN of the S3 bucket to read from. May live in another account (see README)."
  type        = string
}

variable "source_subdirectory" {
  description = "Prefix on the source bucket to transfer. `/` is the whole bucket."
  type        = string
  default     = "/"
}

variable "source_storage_class" {
  description = "Storage class of the source location. Null uses the DataSync default (STANDARD)."
  type        = string
  default     = null
}

variable "destination_bucket_arn" {
  description = "ARN of the S3 bucket to write to. Must be in the account the task runs in."
  type        = string
}

variable "destination_subdirectory" {
  description = "Prefix on the destination bucket to write under. `/` is the whole bucket."
  type        = string
  default     = "/"
}

variable "destination_storage_class" {
  description = "Storage class objects are written with. Null uses the DataSync default (STANDARD)."
  type        = string
  default     = null
}

variable "kms_key_arns" {
  description = "KMS key ARNs the task may use. Required when either bucket is SSE-KMS encrypted."
  type        = list(string)
  default     = []
}

variable "schedule_expression" {
  description = "Cron or rate expression that runs the task on a schedule, e.g. `cron(0 * * * ? *)`. Null leaves it on-demand."
  type        = string
  default     = null
}

variable "excluded_patterns" {
  description = "Simple patterns excluded from the transfer, e.g. `[\"/tmp/*\"]`."
  type        = list(string)
  default     = []
}

variable "included_patterns" {
  description = "Simple patterns to limit the transfer to, e.g. `[\"/uploads/*\"]`."
  type        = list(string)
  default     = []
}

variable "task_options" {
  description = "DataSync task options. Defaults suit an S3-to-S3 copy: transfer only changed objects and never delete on the destination."
  type = object({
    verify_mode            = optional(string, "ONLY_FILES_TRANSFERRED")
    overwrite_mode         = optional(string, "ALWAYS")
    preserve_deleted_files = optional(string, "PRESERVE")
    preserve_devices       = optional(string, "NONE")
    posix_permissions      = optional(string, "NONE")
    uid                    = optional(string, "NONE")
    gid                    = optional(string, "NONE")
    atime                  = optional(string, "BEST_EFFORT")
    mtime                  = optional(string, "PRESERVE")
    transfer_mode          = optional(string, "CHANGED")
    object_tags            = optional(string, "PRESERVE")
    log_level              = optional(string, "BASIC")
  })
  default = {}
}

variable "enable_cloudwatch_logging" {
  description = "Whether to create a CloudWatch log group for the task. False turns task logging off entirely."
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_name" {
  description = "Name of the log group. Defaults to `/aws/datasync/<name>`."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Retention of the DataSync log group."
  type        = number
  default     = 14
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "KMS key ARN encrypting the log group. Null uses the CloudWatch Logs default key."
  type        = string
  default     = null
}

variable "create_cloudwatch_log_resource_policy" {
  description = "Whether to create the log resource policy letting DataSync write to the log group. One policy covers every task in the region, so set false on additional instances."
  type        = bool
  default     = true
}

variable "enable_task_report" {
  description = "Whether the task writes reports to the destination bucket."
  type        = bool
  default     = true
}

variable "task_report_level" {
  description = "Detail of the task report: ERRORS_ONLY or SUCCESSES_AND_ERRORS."
  type        = string
  default     = "ERRORS_ONLY"
}

variable "task_report_output_type" {
  description = "Task report output type: STANDARD or SUMMARY_ONLY."
  type        = string
  default     = "STANDARD"
}

variable "task_report_subdirectory" {
  description = "Prefix on the destination bucket the task reports are written to."
  type        = string
  default     = "/datasync-reports"
}

variable "iam_role_name" {
  description = "Name of the IAM role DataSync assumes. Defaults to `<name>-datasync`."
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "Permissions boundary ARN applied to the IAM role."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all created resources."
  type        = map(string)
  default     = {}
}
