variable "cluster_name" {
  description = "The name of this cluster"
  type        = string
}

variable "engine" {
  description = "Name of the cache engine to be used for the clusters in the replication group. Valid values are redis or valkey"
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "The version of Redis, default 7.1"
  type        = string
  default     = "7.1"
}

variable "parameter_group_name" {
  description = "Parameter group for redis cluster, default is 'default.redis7.cluster.on'"
  type        = string
  default     = "default.redis7.cluster.on"
}

variable "multi_az_enabled" {
  description = "Flag to enable multi az feature, default is false"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes to the cluster right away or waiting to the next maintenance window, default is true"
  type        = bool
  default     = true
}

variable "automatic_failover_enabled" {
  description = "Automatically promote read-replica to become primary when the primary instance down, default is false"
  type        = bool
  default     = false
}

variable "node_type" {
  description = "The node type of this cluster, will affect the memory and bandwidth"
  type        = string
}

variable "cache_node_count" {
  description = "The number of cache node"
  type        = number
}

variable "subnet_ids" {
  description = "The subnet ids of this cluster"
  type        = list(string)
}

variable "security_group_allow_all_within_vpc_id" {
  description = "The security group allow all connection within vpc id"
  type        = string
}

variable "snapshot_window" {
  description = "The time to do the backup, default 01:00-02:00"
  type        = string
  default     = "01:00-02:00"
}

variable "transit_encryption_enabled" {
  description = "Specifies whether to enable in-transit encryption for the ElastiCache replication group. When set to true, it ensures that data between nodes and clients is encrypted in transit."
  type        = bool
  default     = false
}

variable "at_rest_encryption_enabled" {
  description = "Whether to enable encryption at rest."
  type        = bool
  default     = false
}

variable "transit_encryption_mode" {
  description = "A setting that enables clients to migrate to in-transit encryption with no downtime. Valid values are preferred and required. When enabling encryption on an existing replication group, this must first be set to preferred before setting it to required in a subsequent apply"
  type        = string
  default     = null
}

variable "replicas_per_node_group" {
  description = "Number of replica nodes in each node group. Changing this number will trigger a resizing operation before other settings modifications. Valid values are 0 to 5."
  type        = number
  default     = 0
}

variable "custom_redis_parameters" {
  description = "Custom redis parameters to apply to the parameter group"
  type = list(object({
    name  = string
    value = string
  }))
  default = null
}
