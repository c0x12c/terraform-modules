variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used."
  type        = string
}

variable "route_table_ids" {
  description = "One or more route table IDs. Applicable for endpoints of type Gateway"
  type        = list(string)
}

variable "security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface. Applicable for endpoints of type Interface"
  type        = list(string)
}

variable "subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for the endpoint"
  type        = list(string)
}

variable "enable_s3" {
  description = "Enable vpc endpoint for S3 service"
  type        = bool
  default     = false
}

variable "enable_sqs" {
  description = "Enable vpc endpoint for SQS service"
  type        = bool
  default     = false
}

variable "enable_ecr" {
  description = "Enable vpc endpoint for ECR service"
  type        = bool
  default     = false
}

variable "enable_eks" {
  description = "Enable vpc endpoint for EKS service"
  type        = bool
  default     = false
}
