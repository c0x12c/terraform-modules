# Basic configuration
variable "db_name" {
  description = "The name of the database."
  type        = string
}

variable "db_username" {
  description = "The master username for the database."
  type        = string
}

variable "instance_class" {
  description = "The instance class for the database."
  type        = string
  default     = "db.m5.large"
}

variable "disk_size" {
  description = "The disk size of the database instance, in gigabytes."
  type        = number
  default     = 20
}

variable "engine" {
  description = "The database engine to be used (e.g., postgres)."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The version of the database engine to use (default is 16.4)."
  type        = string
  default     = "16.4"
}

variable "port" {
  description = "The port of the database."
  type        = number
  default     = 5432
}

variable "storage_type" {
  description = "The storage type of the RDS instance (standard, gp2, or gp3)."
  type        = string
  default     = "gp3"
}

variable "vpc_id" {
  description = "The ID of the VPC in which the RDS instance will be launched."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "multi_az" {
  description = "Indicates whether the database instance should be deployed across multiple availability zones."
  type        = bool
  default     = false
}

variable "db_subnet_group_name" {
  description = "The subnet group name for instance."
  type        = string
  default     = null
}

# Security
variable "storage_encrypted" {
  description = "Whether the DB instance is encrypted."
  type        = bool
  default     = true
}

variable "iam_database_authentication_enabled" {
  description = "Enable database authentication using AWS IAM."
  type        = bool
  default     = false
}

# Backup and retention
variable "backup_retention_day" {
  description = "The number of days to retain database backups (default is 7 days)."
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Defines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
  default     = true
}

variable "copy_tags_to_snapshot" {
  description = "Indicates whether all instance tags should be copied to snapshots."
  type        = bool
  default     = true
}

# Performance and scaling
variable "max_allocated_storage" {
  description = "The upper limit (in GB) to which Amazon RDS can automatically scale the storage of the DB instance."
  type        = number
  default     = 1000
}

variable "monitoring_interval" {
  description = "The interval in seconds between points when Enhanced Monitoring metrics are collected for the DB instance."
  type        = number
  default     = 0
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled for the DB instance."
  type        = bool
  default     = false
}

# Upgrades
variable "allow_major_version_upgrade" {
  description = "Indicates whether major version upgrades are allowed."
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Indicates whether minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  type        = bool
  default     = false
}

# Replica and other configurations
variable "apply_immediately" {
  description = "Apply any changes to this database immediately."
  type        = bool
  default     = true
}

variable "replica_count" {
  description = "The number of read replicas for the database."
  type        = number
}

variable "supported_engine_version" {
  description = "A list of supported engine versions for the Parameter Groups, supporting Blue-Green deployment."
  type        = list(string)
  default     = []
}

variable "additional_postgres_parameters" {
  description = "Additional postgres parameters to add to parameter groups."
  type = map(object({
    value        = any
    apply_method = string
  }))
  default = null
}

variable "publicly_accessible" {
  description = "Indicates whether the database can be publicly available."
  type        = bool
  default     = false
}

variable "primary_deletion_protection" {
  description = "If the DB primary instance should have deletion protection enabled. The instance can't be deleted when this value is set to true."
  type        = bool
  default     = true
}

variable "replica_deletion_protection" {
  description = "If the DB replicas should have deletion protection enabled. The instances can't be deleted when this value is set to true."
  type        = bool
  default     = true
}

# Database password
variable "use_secret_manager" {
  description = "Whether to use AWS Secret Manager storing Database password."
  type        = bool
  default     = false
}

variable "secret_manager_db_password_name" {
  description = "Secret name created in AWS Secret Manager."
  type        = string
  default     = "POSTGRESQL_PASSWORD"
}

variable "manage_master_user_password" {
  description = "Let AWS own and natively rotate the master password in Secrets Manager. Mutually exclusive with a Terraform-generated password."
  type        = bool
  default     = false

  # A `check` block would only warn. This must hard-fail: the two modes each own the
  # credential, so silently letting one win hides which secret is actually authoritative.
  validation {
    condition     = !(var.manage_master_user_password && var.use_secret_manager)
    error_message = "manage_master_user_password and use_secret_manager are mutually exclusive: AWS cannot own the master password while the module also writes its own Secrets Manager secret."
  }

  # RDS cannot create a read replica from a source whose credentials are managed in
  # Secrets Manager. Enforced uniformly here (this module targets postgres/mysql); without
  # it the combination plans clean and fails at apply, which in a shared single-root blocks
  # unrelated services too.
  validation {
    condition     = !(var.manage_master_user_password && var.replica_count > 0)
    error_message = "manage_master_user_password cannot be combined with replica_count > 0: RDS does not support creating read replicas from a source that manages its master credentials in Secrets Manager."
  }
}

variable "master_user_secret_kms_key_id" {
  description = "KMS key for the managed secret; null uses the AWS-managed key."
  type        = string
  default     = null
}

variable "master_user_secret_rotation_days" {
  description = "Rotate the managed master secret every N days. Null (the default) leaves RDS's own cadence alone, which is every 7 days. Mutually exclusive with master_user_secret_rotation_schedule. Only meaningful with manage_master_user_password."
  type        = number
  default     = null

  # Null, not a number: a concrete default re-cadences every managed instance on version
  # bump, and against RDS's own 7 days any usual value loosens rotation rather than tightens.
  validation {
    condition     = var.master_user_secret_rotation_days == null || var.manage_master_user_password
    error_message = "master_user_secret_rotation_days requires manage_master_user_password: there is no AWS-managed secret to re-cadence when Terraform owns the password."
  }

  # Secrets Manager accepts 1-1000 days. Rejecting here beats an apply-time API error.
  validation {
    condition = var.master_user_secret_rotation_days == null || (
      var.master_user_secret_rotation_days >= 1 && var.master_user_secret_rotation_days <= 1000
    )
    error_message = "master_user_secret_rotation_days must be between 1 and 1000."
  }

  # Secrets Manager rejects both: "you can set the rotation schedule in RotationRules with
  # AutomaticallyAfterDays or ScheduleExpression, but not both."
  validation {
    condition     = var.master_user_secret_rotation_days == null || var.master_user_secret_rotation_schedule == null
    error_message = "master_user_secret_rotation_days and master_user_secret_rotation_schedule are mutually exclusive: Secrets Manager accepts AutomaticallyAfterDays or ScheduleExpression, not both. Use the schedule form to pin rotation to a time of day."
  }
}

variable "master_user_secret_rotation_schedule" {
  description = "A cron() or rate() expression placing rotation of the managed master secret on a specific schedule, in UTC - e.g. cron(0 6 1 * ? *) for 06:00 on the 1st, or rate(10 days). Use instead of master_user_secret_rotation_days when the rotation needs to land at a controlled time rather than N days after the last one."
  type        = string
  default     = null

  validation {
    condition     = var.master_user_secret_rotation_schedule == null || var.manage_master_user_password
    error_message = "master_user_secret_rotation_schedule requires manage_master_user_password: there is no AWS-managed secret to schedule when Terraform owns the password."
  }

  # Secrets Manager's own pattern for ScheduleExpression, max length 256.
  validation {
    condition = var.master_user_secret_rotation_schedule == null || can(
      regex("^[0-9A-Za-z()#?*/, -]{1,256}$", var.master_user_secret_rotation_schedule)
    )
    error_message = "master_user_secret_rotation_schedule must be a cron() or rate() expression using only the characters Secrets Manager accepts, at most 256 long."
  }
}

variable "master_user_secret_rotation_failure_sns_topic_arn" {
  description = "SNS topic to notify when rotation of the managed master secret fails or is abandoned. Null disables the notification. Rotation failing is otherwise silent - the secret stops rotating and nothing surfaces until the next authentication after a failed rotation."
  type        = string
  default     = null

  validation {
    condition = var.master_user_secret_rotation_failure_sns_topic_arn == null || (
      var.master_user_secret_rotation_days != null || var.master_user_secret_rotation_schedule != null
    )
    error_message = "master_user_secret_rotation_failure_sns_topic_arn needs a rotation schedule to watch: also set master_user_secret_rotation_days or master_user_secret_rotation_schedule."
  }
}

variable "master_user_secret_rotation_duration" {
  description = "Length of the rotation window in hours, e.g. \"3h\" - rotation happens at some point inside it. Optional: without it a schedule in hours closes the window after an hour, and a schedule in days closes it at the end of the UTC day. The window must not run into the next UTC day or the next rotation window."
  type        = string
  default     = null

  # A duration alone creates no rotation resource at all, so it would read as configured
  # while doing nothing. Fail rather than ignore it.
  validation {
    condition = var.master_user_secret_rotation_duration == null || (
      var.master_user_secret_rotation_days != null || var.master_user_secret_rotation_schedule != null
    )
    error_message = "master_user_secret_rotation_duration needs a schedule to anchor it: also set master_user_secret_rotation_days or master_user_secret_rotation_schedule."
  }

  # Secrets Manager's Duration pattern is [0-9]+h with a length of 2-3 characters.
  validation {
    condition     = var.master_user_secret_rotation_duration == null || can(regex("^[0-9]{1,2}h$", var.master_user_secret_rotation_duration))
    error_message = "master_user_secret_rotation_duration must be a number of hours followed by h, e.g. \"3h\"."
  }
}

variable "expose_managed_master_password" {
  description = "Opt in to resolving the managed secret's plaintext back into the db_password output. Disabled by default to keep the managed password out of Terraform state. Enable managed credentials on the instance before turning this on: on the apply that first enables them the secret does not exist yet, so db_password resolves to null for that run."
  type        = bool
  default     = false
}

variable "password_length" {
  description = "Database password length."
  type        = number
  default     = 24
}

variable "db_password_rotation_id" {
  description = "Change this to rotate the generated master password. Any new value regenerates it on the next apply; null (the default) leaves the existing password untouched. Ignored when use_secret_manager or manage_master_user_password is set. String rather than number so callers can use a date, e.g. \"2026-08\"."
  type        = string
  default     = null
}

# Logging
variable "cloudwatch_exported_log_types" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine). MySQL and MariaDB: audit, error, general, slowquery. PostgreSQL: postgresql, upgrade. MSSQL: agent , error. Oracle: alert, audit, listener, trace."
  type        = list(string)
  default     = null
}
