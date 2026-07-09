# --- Naming -------------------------------------------------------------------

variable "name" {
  description = "Name for the DataSync task and the base name for related resources (locations, IAM role, log group)."
  type        = string
}

# --- Source location ----------------------------------------------------------
# Set exactly one of source_s3, source_object_storage, or source_location_arn.

variable "source_s3" {
  description = "Create an S3 location as the source. When bucket_access_role_arn is null, the module creates a least-privilege DataSync access role scoped to the bucket."
  type = object({
    s3_bucket_arn          = string
    subdirectory           = optional(string, "/")
    bucket_access_role_arn = optional(string)
    s3_storage_class       = optional(string)
  })
  default = null
}

variable "source_object_storage" {
  description = "Create an S3-compatible object-storage location (e.g. Google Cloud Storage, MinIO) as the source. agent_arns is required; the module does not create DataSync agents."
  type = object({
    server_hostname = string
    bucket_name     = string
    agent_arns      = list(string)
    subdirectory    = optional(string)
    access_key      = optional(string)
    secret_key      = optional(string)
    server_protocol = optional(string)
    server_port     = optional(number)
  })
  default = null
}

variable "source_location_arn" {
  description = "Bring-your-own ARN of an existing DataSync location to use as the source (for location types the module does not create)."
  type        = string
  default     = null
}

# --- Destination location -----------------------------------------------------
# Set exactly one of destination_s3, destination_object_storage, or destination_location_arn.

variable "destination_s3" {
  description = "Create an S3 location as the destination. When bucket_access_role_arn is null, the module creates a least-privilege DataSync access role scoped to the bucket."
  type = object({
    s3_bucket_arn          = string
    subdirectory           = optional(string, "/")
    bucket_access_role_arn = optional(string)
    s3_storage_class       = optional(string)
  })
  default = null
}

variable "destination_object_storage" {
  description = "Create an S3-compatible object-storage location (e.g. Google Cloud Storage, MinIO) as the destination. agent_arns is required; the module does not create DataSync agents."
  type = object({
    server_hostname = string
    bucket_name     = string
    agent_arns      = list(string)
    subdirectory    = optional(string)
    access_key      = optional(string)
    secret_key      = optional(string)
    server_protocol = optional(string)
    server_port     = optional(number)
  })
  default = null
}

variable "destination_location_arn" {
  description = "Bring-your-own ARN of an existing DataSync location to use as the destination (for location types the module does not create)."
  type        = string
  default     = null
}

# --- Task ---------------------------------------------------------------------

variable "schedule_expression" {
  description = "Schedule for the task as a rate() or cron() expression. When null the task runs only on manual start."
  type        = string
  default     = null
}

variable "options" {
  description = "DataSync task options. When null the options block is omitted and AWS defaults apply. Each attribute maps to the aws_datasync_task options block."
  type = object({
    atime                          = optional(string)
    bytes_per_second               = optional(number)
    gid                            = optional(string)
    log_level                      = optional(string)
    mtime                          = optional(string)
    object_tags                    = optional(string)
    overwrite_mode                 = optional(string)
    posix_permissions              = optional(string)
    preserve_deleted_files         = optional(string)
    preserve_devices               = optional(string)
    security_descriptor_copy_flags = optional(string)
    task_queueing                  = optional(string)
    transfer_mode                  = optional(string)
    uid                            = optional(string)
    verify_mode                    = optional(string)
  })
  default = null
}

variable "include_patterns" {
  description = "List of SIMPLE_PATTERN filters limiting which files are transferred. Joined with '|' into the task includes block. Empty means no include filter."
  type        = list(string)
  default     = []
}

variable "exclude_patterns" {
  description = "List of SIMPLE_PATTERN filters excluding files from the transfer. Joined with '|' into the task excludes block. Empty means no exclude filter."
  type        = list(string)
  default     = []
}

# --- CloudWatch logging -------------------------------------------------------

variable "create_cloudwatch_log_group" {
  description = "Whether to create a CloudWatch log group for the task and a resource policy allowing DataSync to write to it. Mutually exclusive with cloudwatch_log_group_arn."
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_name" {
  description = "Name of the log group to create. Defaults to /aws/datasync/<name>."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Retention in days for the created log group."
  type        = number
  default     = 14
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "ARN of the KMS key used to encrypt the created log group. If null, logs are encrypted with the CloudWatch-managed key."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of an existing CloudWatch log group to wire to the task. Ignored when create_cloudwatch_log_group is true."
  type        = string
  default     = null
}

# --- Tags ---------------------------------------------------------------------

variable "tags" {
  description = "Tags applied to all taggable resources."
  type        = map(string)
  default     = {}
}
