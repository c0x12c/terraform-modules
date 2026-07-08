# --- Cluster identification ---------------------------------------------------

variable "name" {
  description = "The cluster identifier and base name for related resources (subnet group, security group, parameter group, instances)."
  type        = string
}

variable "engine_version" {
  description = "DocumentDB engine version."
  type        = string
  default     = "5.0.0"
}

variable "master_username" {
  description = "Username for the master DB user."
  type        = string
}

variable "master_password" {
  description = "Master DB password. If null, a random password is generated and stored in the connection secret."
  type        = string
  default     = null
  sensitive   = true
}

variable "password_length" {
  description = "Length of the generated master password when master_password is null."
  type        = number
  default     = 32
}

variable "database_name" {
  description = "Database name used in the connection URI path. DocumentDB creates databases lazily, so this only shapes the URI. If null, the URI has an empty path."
  type        = string
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
  description = "Map of ingress rules for the cluster security group. Each value may set source_security_group_id (preferred for VPC services) and/or cidr_blocks. from_port/to_port default to the DocumentDB port (27017)."
  type = map(object({
    source_security_group_id = optional(string)
    cidr_blocks              = optional(list(string))
    description              = optional(string)
    from_port                = optional(number)
    to_port                  = optional(number)
  }))
  default = {}
}

# --- Instances ----------------------------------------------------------------

variable "instance_class" {
  description = "Instance class for the DocumentDB cluster instances."
  type        = string
  default     = "db.t3.medium"
}

variable "instance_count" {
  description = "Number of cluster instances to create. 1 is the minimal single-node setup; add more for HA."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1
    error_message = "instance_count must be at least 1."
  }
}

variable "auto_minor_version_upgrade" {
  description = "Whether minor engine upgrades are applied automatically during the maintenance window."
  type        = bool
  default     = true
}

# --- Storage and encryption ---------------------------------------------------

variable "storage_encrypted" {
  description = "Whether the cluster storage is encrypted."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN of the KMS key used for storage encryption. If null, the default DocumentDB-managed key is used."
  type        = string
  default     = null
}

# --- Backup and retention -----------------------------------------------------

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 1
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

variable "apply_immediately" {
  description = "Whether to apply changes immediately, instead of waiting for the next maintenance window."
  type        = bool
  default     = false
}

# --- Logging ------------------------------------------------------------------

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch Logs (e.g. audit, profiler)."
  type        = list(string)
  default     = []
}

# --- TLS / parameter group ----------------------------------------------------

variable "tls_enabled" {
  description = "Whether TLS is required for client connections. Sets the `tls` cluster parameter and shapes the connection URI."
  type        = bool
  default     = true
}

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
  description = "Family for the cluster parameter group (e.g. docdb5.0)."
  type        = string
  default     = "docdb5.0"
}

variable "db_cluster_parameter_group_parameters" {
  description = "Additional parameters to set on the cluster parameter group (the `tls` parameter is managed via tls_enabled)."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "pending-reboot")
  }))
  default = []
}

# --- Connection secret --------------------------------------------------------

variable "create_secret" {
  description = "Whether to store the connection details (host, port, credentials, URI) in a Secrets Manager secret."
  type        = bool
  default     = true
}

variable "secret_name" {
  description = "Name of the Secrets Manager secret. Defaults to `<name>-connection`."
  type        = string
  default     = null
}

variable "secret_recovery_window_in_days" {
  description = "Recovery window for the Secrets Manager secret. 0 forces immediate deletion (useful in dev)."
  type        = number
  default     = 7
}

variable "secret_kms_key_id" {
  description = "KMS key ID used to encrypt the connection secret. Defaults to aws/secretsmanager."
  type        = string
  default     = null
}

# --- Tags ---------------------------------------------------------------------

variable "tags" {
  description = "Tags applied to all created resources."
  type        = map(string)
  default     = {}
}
