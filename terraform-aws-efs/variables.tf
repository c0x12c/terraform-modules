variable "name" {
  type        = string
  description = "Name of the resources will be created."
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

variable "subnet_ids" {
  type        = list(string)
  description = "A list subnet IDs for the EFS"
}

variable "efs_access_points" {
  type = map(object({
    posix_user = optional(object({
      gid = optional(number, 1000)
      uid = optional(number, 1000)
    }), { gid = 1000, uid = 1000 }) # Default posix_user

    root_directory = object({
      path = string
      creation_info = optional(object({
        owner_gid   = optional(number, 1000)
        owner_uid   = optional(number, 1000)
        permissions = optional(string, "755")
      }), { owner_gid = 1000, owner_uid = 1000, permissions = "755" }) # Default creation_info
    })
  }))
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy to"
}

variable "allowed_security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs to allow access to the EFS"
}
