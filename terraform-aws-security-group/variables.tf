variable "security_groups" {
  description = "A map of security groups with their associated ingress and egress rules, to be applied to a VPC."
  type = map(object({
    name        = string
    description = string
    vpc_id      = string
    ingress_rules = optional(map(object({
      from_port   = optional(number, null) # Port range start for ingress traffic, null means not specified
      to_port     = optional(number, null) # Port range end for ingress traffic, null means not specified
      protocol    = optional(string, null) # Protocol for ingress traffic (e.g., 'tcp', 'udp', etc.), null means not specified
      cidr_ipv4   = optional(string, null) # IPv4 CIDR block for ingress traffic, null means not specified
      cidr_ipv6   = optional(string, null) # IPv6 CIDR block for ingress traffic, null means not specified
      description = optional(string, null) # Description of the ingress rule, null means not specified
      self        = optional(bool, false)  # Whether to allow traffic from the security group itself, defaults to false
    })), null)                             # A map of ingress rules for the security group, can be null if no ingress rules are specified
    egress_rules = optional(map(object({
      from_port   = optional(number, null) # Port range start for egress traffic, null means not specified
      to_port     = optional(number, null) # Port range end for egress traffic, null means not specified
      protocol    = optional(string, null) # Protocol for egress traffic (e.g., 'tcp', 'udp', etc.), null means not specified
      cidr_ipv4   = optional(string, null) # IPv4 CIDR block for egress traffic, null means not specified
      cidr_ipv6   = optional(string, null) # IPv6 CIDR block for egress traffic, null means not specified
      description = optional(string, null) # Description of the egress rule, null means not specified
      self        = optional(bool, false)  # Whether to allow traffic to the security group itself, defaults to false
    })), null)
    tags = optional(map(string), {}) # A map of egress rules for the security group, can be null if no egress rules are specified
  }))
  default = null # Default to null if no security groups are defined
}

variable "create_default_security_group" {
  description = "Flag to determine whether a default security group should be created."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the main VPC associated with the security groups. Can be null if not provided."
  type        = string
  default     = null
}

variable "cidr_blocks" {
  description = "List of allowed CIDR blocks used to define ingress/egress rules for the security groups."
  type        = list(string)
  default     = []
}

variable "ipv6_cidr_blocks" {
  description = "List of allowed IPv6 CIDR blocks used to define ingress/egress rules for the security groups."
  type        = list(string)
  default     = []
}

# migration purpose
variable "custom_sg_allow_all_description" {
  description = "Custom description for security group allow all `aws_security_group.allow_all`."
  type        = string
  default     = null
}

variable "custom_sg_allow_all_within_vpc_description" {
  description = "Custom description for security group allow all within vpc `aws_security_group.allow_all_within_vpc`."
  type        = string
  default     = null
}

variable "custom_sg_allow_all_within_vpc_egress_ipv6_cidr_blocks" {
  description = "Custom IPv6 CIDR blocks to allow in the egress rules for the security group allow_all_within_vpc"
  type        = list(string)
  default     = ["::/0"]
}
