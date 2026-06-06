variable "region" {
  description = "The GCP region in which the resources are created."
  type        = string
}

variable "name" {
  description = "The name of redis cluster to create."
  type        = string
}

variable "vpc_id" {
  description = "The ID of VPC in which the resources are created."
  type        = string
}

variable "replica_count" {
  description = "The number of replica nodes per shard."
  type        = number
  default     = 1
}

variable "shard_count" {
  description = "The number of shards to for redis cluster."
  type        = number
  default     = 3
}

variable "authorization_mode" {
  description = "The authorization mode of the Redis cluster. If not provided, auth feature is disabled for the cluster. Default value is AUTH_MODE_DISABLED. Possible values are: AUTH_MODE_UNSPECIFIED, AUTH_MODE_IAM_AUTH, AUTH_MODE_DISABLED."
  type        = string
  default     = "AUTH_MODE_DISABLED"
  validation {
    condition     = var.authorization_mode == "AUTH_MODE_UNSPECIFIED" || var.authorization_mode == "AUTH_MODE_IAM_AUTH" || var.authorization_mode == "AUTH_MODE_DISABLED"
    error_message = "Sorry, value must be either 'AUTH_MODE_UNSPECIFIED', 'AUTH_MODE_IAM_AUTH', or 'AUTH_MODE_DISABLED'."
  }
}

variable "transit_encryption_mode" {
  description = "The in-transit encryption for the Redis cluster. If not provided, encryption is disabled for the cluster. Default value is TRANSIT_ENCRYPTION_MODE_DISABLED. Possible values are: TRANSIT_ENCRYPTION_MODE_UNSPECIFIED, TRANSIT_ENCRYPTION_MODE_DISABLED, TRANSIT_ENCRYPTION_MODE_SERVER_AUTHENTICATION."
  type        = string
  default     = "TRANSIT_ENCRYPTION_MODE_DISABLED"
  validation {
    condition     = var.transit_encryption_mode == "TRANSIT_ENCRYPTION_MODE_UNSPECIFIED" || var.transit_encryption_mode == "TRANSIT_ENCRYPTION_MODE_DISABLED" || var.transit_encryption_mode == "TRANSIT_ENCRYPTION_MODE_SERVER_AUTHENTICATION"
    error_message = "Sorry, value must be either 'AUTH_MODE_UNSPECIFIED', 'AUTH_MODE_IAM_AUTH', or 'AUTH_MODE_DISABLED'."
  }
}

variable "node_type" {
  description = "The node type for the Redis cluster. Possible values are: REDIS_SHARED_CORE_NANO, REDIS_HIGHMEM_MEDIUM, REDIS_HIGHMEM_XLARGE, REDIS_STANDARD_SMALL."
  type        = string
  default     = "REDIS_HIGHMEM_MEDIUM"
  validation {
    condition     = contains(["REDIS_SHARED_CORE_NANO", "REDIS_HIGHMEM_MEDIUM", "REDIS_HIGHMEM_XLARGE", "REDIS_STANDARD_SMALL"], var.node_type)
    error_message = "The node_type must be one of: REDIS_SHARED_CORE_NANO, REDIS_HIGHMEM_MEDIUM, REDIS_HIGHMEM_XLARGE, REDIS_STANDARD_SMALL."
  }
}
