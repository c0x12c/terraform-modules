# --- Cluster identification ----------------------------------------------------

variable "name" {
  description = "The cluster identifier and the base name used for related resources (subnet group, security group, parameter groups, instances)."
  type        = string
}

variable "engine" {
  description = "Database engine. Aurora engines (`aurora-postgresql`, `aurora-mysql`) provision an Aurora cluster with separate cluster instances. Non-Aurora engines (`postgres`, `mysql`) provision a Multi-AZ DB cluster managed by the cluster resource itself."
  type        = string

  validation {
    condition     = contains(["aurora-postgresql", "aurora-mysql", "postgres", "mysql"], var.engine)
    error_message = "engine must be one of: aurora-postgresql, aurora-mysql, postgres, mysql."
  }
}

variable "engine_version" {
  description = "The database engine version."
  type        = string
}

variable "engine_mode" {
  description = "Engine mode for Aurora clusters. Ignored for Multi-AZ DB cluster."
  type        = string
  default     = "provisioned"
}

variable "database_name" {
  description = "Name of the initial database to create. If null, no database is created."
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user."
  type        = string
}

variable "port" {
  description = "Port the database accepts connections on. Defaults to 5432 (postgres) or 3306 (mysql)."
  type        = number
  default     = null
}

# --- Networking ---------------------------------------------------------------

variable "vpc_id" {
  description = "The VPC ID in which the cluster will be deployed."
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for the DB subnet group. Required when create_db_subnet_group is true."
  type        = list(string)
  default     = []
}

variable "create_db_subnet_group" {
  description = "Whether to create a DB subnet group from `subnets`. Set false to bring your own."
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "Name of an existing DB subnet group to use (when create_db_subnet_group is false), or override name when creating."
  type        = string
  default     = null
}

variable "security_group_rules" {
  description = "Map of ingress rules for the cluster security group. Each value may set source_security_group_id (preferred for VPC services) and/or cidr_blocks. from_port/to_port default to the database port."
  type = map(object({
    source_security_group_id = optional(string)
    cidr_blocks              = optional(list(string))
    description              = optional(string)
    from_port                = optional(number)
    to_port                  = optional(number)
  }))
  default = {}
}

# --- Aurora cluster instances -------------------------------------------------

variable "instances" {
  description = "Map of Aurora cluster instances to create. Key is the suffix appended to the cluster name. Empty for Multi-AZ DB cluster."
  type = map(object({
    instance_class          = optional(string)
    availability_zone       = optional(string)
    publicly_accessible     = optional(bool)
    promotion_tier          = optional(number)
    db_parameter_group_name = optional(string)
  }))
  default = {}
}

variable "instance_class" {
  description = "Default instance class for Aurora cluster instances when not overridden per-instance."
  type        = string
  default     = "db.r6g.large"
}

variable "serverlessv2_scaling_configuration" {
  description = "Aurora Serverless v2 scaling configuration. When set, instance_class is forced to db.serverless. Aurora engines only."
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

# --- Multi-AZ DB cluster (mysql / postgres) -----------------------------------

variable "allocated_storage" {
  description = "Allocated storage in GB. Required for Multi-AZ DB cluster, must be null for Aurora."
  type        = number
  default     = null
}

variable "db_cluster_instance_class" {
  description = "Instance class for Multi-AZ DB cluster (e.g. db.r6gd.large). Required for Multi-AZ DB cluster, must be null for Aurora."
  type        = string
  default     = null
}

variable "iops" {
  description = "Provisioned IOPS for io1/io2 storage on Multi-AZ DB cluster. Optional for gp3 ≥3000."
  type        = number
  default     = null
}

variable "storage_type" {
  description = "Storage type. For Multi-AZ DB cluster: io1, io2, or gp3 (required). For Aurora: usually null (or aurora-iopt1)."
  type        = string
  default     = null
}

# --- Storage and encryption ---------------------------------------------------

variable "storage_encrypted" {
  description = "Whether the cluster storage is encrypted."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN of the KMS key used for storage encryption. If null, the default RDS-managed key is used."
  type        = string
  default     = null
}

# --- Backup and retention -----------------------------------------------------

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Daily UTC window when automated backups are taken (HH:MM-HH:MM)."
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Weekly UTC window for system maintenance (ddd:HH:MM-ddd:HH:MM)."
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot before destroying the cluster."
  type        = bool
  default     = false
}

variable "copy_tags_to_snapshot" {
  description = "Whether to copy cluster tags to snapshots."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled. Defaults to true; must be flipped to false before a destroy."
  type        = bool
  default     = true
}

# --- Upgrades and apply -------------------------------------------------------

variable "allow_major_version_upgrade" {
  description = "Whether major engine version upgrades are allowed."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Whether minor engine upgrades are applied automatically during the maintenance window."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately, instead of waiting for the next maintenance window."
  type        = bool
  default     = false
}

# --- Monitoring ---------------------------------------------------------------

variable "monitoring_interval" {
  description = "Interval in seconds for Enhanced Monitoring. 0 disables. Production recommendation: 30 or 60."
  type        = number
  default     = 0
}

variable "create_monitoring_role" {
  description = "Whether the module should create the IAM role used for Enhanced Monitoring. Set false and provide monitoring_role_arn to bring your own."
  type        = bool
  default     = true
}

variable "monitoring_role_arn" {
  description = "ARN of an existing IAM role for Enhanced Monitoring. Used when create_monitoring_role is false."
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Whether Performance Insights are enabled."
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention in days. 7 is free; 31, 93, 186, 372, 731 are paid tiers."
  type        = number
  default     = 7
}

variable "performance_insights_kms_key_id" {
  description = "KMS key ID used to encrypt Performance Insights data."
  type        = string
  default     = null
}

# --- IAM authentication -------------------------------------------------------

variable "iam_database_authentication_enabled" {
  description = "Whether IAM database authentication is enabled."
  type        = bool
  default     = false
}

# --- Logging ------------------------------------------------------------------

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to CloudWatch Logs. PostgreSQL: postgresql. MySQL: audit, error, general, slowquery."
  type        = list(string)
  default     = []
}

# --- Master password ----------------------------------------------------------

variable "manage_master_user_password" {
  description = "Use AWS-managed master user password (stored in Secrets Manager, auto-rotated by RDS). Recommended."
  type        = bool
  default     = true
}

variable "master_user_secret_kms_key_id" {
  description = "KMS key ID used to encrypt the AWS-managed master user secret. Defaults to aws/secretsmanager."
  type        = string
  default     = null
}

# --- Cluster parameter group --------------------------------------------------

variable "create_db_cluster_parameter_group" {
  description = "Whether to create a DB cluster parameter group. Set false to bring your own."
  type        = bool
  default     = true
}

variable "db_cluster_parameter_group_name" {
  description = "Name of an existing cluster parameter group to use when create_db_cluster_parameter_group is false."
  type        = string
  default     = null
}

variable "db_cluster_parameter_group_family" {
  description = "Family for the cluster parameter group (e.g. aurora-postgresql16, postgres16). Required when creating."
  type        = string
  default     = null
}

variable "db_cluster_parameter_group_parameters" {
  description = "List of parameters to set on the cluster parameter group."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

# --- Instance parameter group (Aurora only) -----------------------------------

variable "create_db_parameter_group" {
  description = "Whether to create a DB instance parameter group (Aurora only)."
  type        = bool
  default     = true
}

variable "db_parameter_group_name" {
  description = "Name of an existing instance parameter group to use when create_db_parameter_group is false."
  type        = string
  default     = null
}

variable "db_parameter_group_family" {
  description = "Family for the instance parameter group. Defaults to db_cluster_parameter_group_family."
  type        = string
  default     = null
}

variable "db_parameter_group_parameters" {
  description = "List of parameters to set on the instance parameter group."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

# --- Tags ---------------------------------------------------------------------

variable "tags" {
  description = "Tags applied to all created resources."
  type        = map(string)
  default     = {}
}
