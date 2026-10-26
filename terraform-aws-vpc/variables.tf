variable "name" {
  description = "The name of your VPC"
  type        = string
}

variable "region" {
  description = "The region of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "availability_zone_postfixes" {
  description = "List of availability zones"
  type        = list(string)
}

variable "single_nat" {
  description = "Whether to create a single NAT gateway or one per AZ"
  type        = bool
  default     = false
}

variable "create_custom_subnets" {
  description = "Whether to create custom subnets."
  type        = bool
  default     = false
}

variable "custom_public_subnets" {
  description = "List of custom public subnets."
  type        = list(string)
  default     = []
}

variable "custom_private_subnets" {
  description = "List of custom private subnets."
  type        = list(string)
  default     = []
}

variable "create_database_subnets" {
  description = "Whether to create database subnets, one per availability zone, with a route table that has no route to the internet."
  type        = bool
  default     = false
}

variable "custom_database_subnets" {
  description = "List of custom database subnets, one per availability zone. Used when both create_custom_subnets and create_database_subnets are true."
  type        = list(string)
  default     = []

  validation {
    condition     = !(var.create_custom_subnets && var.create_database_subnets) || length(var.custom_database_subnets) == length(var.availability_zone_postfixes)
    error_message = "custom_database_subnets needs one CIDR per availability zone when create_custom_subnets and create_database_subnets are both true."
  }
}

variable "create_flow_log" {
  description = "Whether to create VPC flow logs."
  type        = bool
  default     = false
}

variable "create_private_database_subnet_group" {
  description = "Whether to create private database subnet group"
  type        = bool
  default     = false
}

variable "cluster_names" {
  description = "List of EKS cluster names within with VPC"
  type        = list(string)
  default     = []
}

variable "created_managed_node_group" {
  description = "Whether Managed Node Groups are created in this VPC"
  type        = bool
  default     = false
}

variable "custom_acls" {
  description = "List of custom ACLs that overrides AWS default ACLs."
  type = map(object({
    rule_number = number
    cidr_block  = string
    protocol    = string
    rule_action = string
    egress      = optional(bool, false)
    from_port   = optional(number, null)
    to_port     = optional(number, null)
    icmp_type   = optional(string, null)
    icmp_code   = optional(string, null)
  }))
  default = null
}
