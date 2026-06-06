# Basic configuration
variable "identifier" {
  description = "The database identifier."
  type        = string
}

variable "db_name" {
  description = "The name of the database."
  type        = string
  default     = null
}

variable "username" {
  description = "The username for the master DB user."
  type        = string
  default     = null
}

variable "password" {
  description = "The password for the master DB user."
  type        = string
  default     = null
  sensitive   = true
}

variable "instance_class" {
  description = "The instance class for the database."
  type        = string
  default     = "db.m5.large"
}

variable "allocated_storage" {
  description = "The amount of allocated storage (in gigabytes) for the DB instance."
  type        = number
  default     = 20
}

variable "engine" {
  description = "The database engine to use."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The version of Postgres database, default 16.4."
  type        = string
  default     = "16.4"
}

variable "port" {
  description = "The port of the database."
  type        = number
  default     = 5432
}

variable "db_subnet_group_name" {
  description = "A DB subnet group to associate with this DB instance."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "A list of VPC security groups to associate with the DB instance."
  type        = list(string)
  default     = []
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true."
  type        = bool
  default     = true
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or not the mappings of AWS IAM accounts to database accounts are enabled."
  type        = bool
  default     = false
}

# Storage and encryption
variable "storage_type" {
  description = "The storage type of RDS instance. It can be standard, gp2 or gp3."
  type        = string
  default     = "gp3"
}

variable "max_allocated_storage" {
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance."
  type        = number
  default     = 1000
}

variable "storage_encrypted" {
  description = "Whether the DB instance is encrypted."
  type        = bool
  default     = true
}

# Backup and retention
variable "backup_retention_period" {
  description = "Backup retention day, default 7 days."
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted."
  type        = string
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "Tags existing on instance are copied to snapshot."
  type        = bool
  default     = true
}

# Security
variable "publicly_accessible" {
  description = "Boolean indicating if the DB instance is publicly accessible."
  type        = bool
  default     = false
}

# Monitoring and Performance
variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance."
  type        = number
  default     = 0
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled."
  type        = bool
  default     = false
}

# Upgrade and Maintenance
variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed."
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  type        = bool
  default     = false
}

# Apply Changes
variable "apply_immediately" {
  description = "Enable the feature apply the changes to this database immediately."
  type        = bool
  default     = true
}

# Read Replica and Other Settings
variable "parameter_group_name" {
  description = "The name of the DB parameter group to associate with this instance."
  type        = string
}

variable "replicate_source_db" {
  description = "The ARN of the source DB instance if this Amazon RDS DB instance is a read replica."
  type        = string
  default     = null
}

# Multi AZ
variable "multi_az" {
  description = "Indicates whether the database instance should be deployed across multiple availability zones"
  type        = bool
  default     = false
}

# Logging
variable "cloudwatch_exported_log_types" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine). MySQL and MariaDB: audit, error, general, slowquery. PostgreSQL: postgresql, upgrade. MSSQL: agent , error. Oracle: alert, audit, listener, trace."
  type        = list(string)
  default     = null
}
