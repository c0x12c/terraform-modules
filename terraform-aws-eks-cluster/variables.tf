variable "region" {
  type        = string
  description = "Region of the EKS cluster."
  default     = null
}

variable "cluster_version" {
  description = "The Kubernetes version for creating the cluster."
  default     = "1.32"
  type        = string
}

variable "environment" {
  type        = string
  description = "The environment name, will be used in components's name."
}

variable "name" {
  type        = string
  description = "The prefix name that will be used in cluster and components's name."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs that will be used in additional to the default ones."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC that the cluster will be created on."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR for creating default security groups"
}
variable "public_subnet_ids" {
  type        = list(string)
  description = "The public subnet IDs in the associated VPC"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The private subnet IDs in the associated VPC"
}

variable "compute_type" {
  type        = string
  description = "The type of compute resources to be used, e.g., 'ec2' or 'fargate'."
  default     = "ec2"
}

variable "aws_auth_users" {
  type        = list(any)
  description = "AWS users for authenticating with Kubernetes"
  default     = []
}

variable "aws_auth_accounts" {
  type        = list(any)
  description = "AWS accounts for authenticating with Kubernetes"
  default     = []
}

variable "create_fargate_profile" {
  type        = bool
  description = "Specify whether creating the Fargate profile for running pods."
  default     = false
}

variable "fargate_profiles" {
  type        = any
  description = "Configuration block(s) for selecting Kubernetes Pods to execute with this Fargate Profile"
  default     = {}
}

variable "fargate_timeouts" {
  type = object({
    create = string
    delete = string
  })
  description = "Default timeout attributes."
  default = {
    create = "20m"
    delete = "20m"
  }
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

variable "efs_filesystem_name" {
  description = "To specify the name of efs filesystem in case overwrite the default one"
  type        = string
  default     = null
}

variable "node_groups" {
  description = "Key-value mapping of Kubernetes node groups attributes"
  default     = {}
  type = map(object({
    node_group_name = string
    disk_size       = number
    instance_types  = list(string)
    desired_size    = number
    max_size        = number
    min_size        = number
    labels          = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
}

variable "update_config" {
  description = "Configuration block of settings for max unavailable resources during node group updates"
  type        = map(string)
  default = {
    max_unavailable_percentage = 33
  }
}

variable "node_repair_config" {
  description = "The node auto repair configuration for the node group"
  type        = bool
  default     = true
}

variable "administrator_role_arn" {
  type        = string
  default     = null
  description = "AWS Administrator role arn for mapping with K8s RBAC"
}

variable "default_service_account" {
  type        = string
  description = "Default service account name for binding with Datadog"
  default     = "default"
}

variable "custom_service_accounts" {
  type        = map(list(string))
  description = <<EOF
Map of service account names for binding with Datadog.
Each key represents a namespace, and the value is a list of service account names.
  {
    namespace = ["service-account1", "service-account2] 
  }
EOF
  default     = {}
}

variable "enabled_datadog_agent" {
  type        = bool
  description = "Enable datadog integration RBAC creation"
  default     = false
}

variable "datadog_agent_cluster_role_name" {
  type        = string
  description = "Name of the ClusterRole to create in order to configure Datadog Agents"
  default     = "datadog-agent"
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "Enabled logging types for EKS Control Plane"
}

variable "enabled_cloudwatch_logging" {
  type        = bool
  default     = false
  description = "Enable logging for Kubernetes Pods through built in EKS Fargate Firelens"
}

variable "enabled_efs" {
  type        = bool
  description = "Enable EFS creation for persistence volumes"
  default     = false
}

variable "custom_namespaces" {
  type        = list(string)
  description = "Custom namespaces to be created during initialization"
  default     = []
}

variable "addons_vpc_cni_version" {
  type        = string
  description = "The version of the VPC CNI addon, latest by default"
  default     = null
}

variable "addons_kube_proxy_version" {
  type        = string
  description = "The version of the kube-proxy addon, latest by default"
  default     = null
}

variable "addons_coredns_version" {
  type        = string
  description = "The version of the CoreDNS addon, latest by default"
  default     = null
}

variable "addons_efs_csi_driver_version" {
  type        = string
  description = "The version of the EFS CSI Driver addon, latest by default"
  default     = null
}

variable "enabled_endpoint_private_access" {
  type        = bool
  default     = true
  description = "Enable private access for the Kubernetes API server endpoint."
}

variable "enabled_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Enable public access for the Kubernetes API server endpoint."
}

variable "public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks allowed for public access to the Kubernetes API server endpoint."
}

variable "enable_access_config" {
  description = "Enable or disable access configuration for the Kubernetes cluster."
  type        = bool
  default     = false
}

variable "authentication_mode" {
  description = "The authentication mode, allowed values are CONFIG_MAP, API, or API_AND_CONFIG_MAP."
  type        = string
  default     = "API"
  validation {
    condition     = var.authentication_mode == "CONFIG_MAP" || var.authentication_mode == "API" || var.authentication_mode == "API_AND_CONFIG_MAP"
    error_message = "Invalid value for authentication_mode. Allowed values are CONFIG_MAP, API, or API_AND_CONFIG_MAP."
  }
}

variable "create_fargate_profile_access_entry" {
  description = "Create access entry for Fargate profile"
  type        = bool
  default     = false
}

variable "enabled_karpenter" {
  description = "Whether to integrate Karpenter to cluster"
  type        = bool
  default     = false
}

variable "coredns" {
  description = "Configuration for CoreDNS add-on"
  type = object({
    replica_count = optional(number, 1)
    node_selector = optional(map(string), {})
    tolerations = optional(list(object({
      key      = string
      operator = string
      value    = optional(string)
      effect   = optional(string)
    })), [])
  })
  default = {
    replica_count = 1
    node_selector = {}
    tolerations   = []
  }
}

variable "efs_csi" {
  description = "Configuration for EFS CSI add-on"
  type = object({
    replica_count = optional(number, 1)
    node_selector = optional(map(string), {})
    tolerations = optional(list(object({
      key      = string
      operator = string
      value    = optional(string)
      effect   = optional(string)
    })), [])
  })
  default = {
    replica_count = 1
    node_selector = {}
    tolerations   = []
  }
}

variable "node_group_version" {
  type        = string
  description = "Kubernetes version for the managed node group"
  default     = "1.32"
}
