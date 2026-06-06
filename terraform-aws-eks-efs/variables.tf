variable "name" {
  type        = string
  description = "Name of the resources will be created."
}

variable "environment" {
  type        = string
  description = "Environment where the resources will be created."
}

variable "filesystem_encrypted" {
  description = "Enable encryption for EFS"
  default     = true
  type        = bool
}

variable "filesystem_performance_mode" {
  description = "The file system performance mode."
  type        = string
  default     = "generalPurpose"
}

variable "filesystem_throughput_mode" {
  description = "Throughput mode for the file system."
  type        = string
  default     = "bursting"
}

variable "efs_storage_class_name" {
  type    = string
  default = "efs"
}

variable "efs_backup_policy_status" {
  description = "Enable/disable backup for EFS Filesystem.  Value should be ENABLE/DISABLED.  Defaults to DISABLED"
  type        = string
  default     = "DISABLED"
  validation {
    condition     = var.efs_backup_policy_status == "ENABLED" || var.efs_backup_policy_status == "DISABLED"
    error_message = "Sorry, value must be either 'ENABLED' or 'DISABLED'."
  }
}

variable "efs_lifecycle_policy" {
  description = "Lifecycle Policy for the EFS Filesystem"
  type = list(object({
    transition_to_ia                    = string
    transition_to_primary_storage_class = string
  }))
  default = []
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "A list of private subnet IDs for the EFS"
}

variable "cluster_security_group_id" {
  type        = string
  description = "Security group to apply to this cluster."
}

variable "efs_filesystem_name" {
  description = "To specify the name of efs filesystem in case overwrite the default one"
  type        = string
  default     = null
}
