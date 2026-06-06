variable "name" {
  description = "the name of the alb"
  type        = string
}

variable "public_subnets" {
  description = "A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type `network`. Changing this value for load balancers of type `network` will force a recreation of the resource"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of VPC"
  type        = string
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the LB"
  type        = list(string)
  default     = []
}

variable "certificate_arn" {
  description = "The ARN of the certificate that the ALB uses for https"
  type        = string
}

variable "health_check_path" {
  description = "Path to check if the service is healthy, e.g. \"/status\""
  type        = string
}

variable "idle_timeout" {
  description = "ALB idle timeout"
  type        = number
  default     = 60
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "enabled_http_port" {
  description = "Whether to allow HTTP (80) port through ALB security group."
  type        = bool
  default     = true
}

variable "internal" {
  description = "If true, the LB will be internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer."
  type        = bool
  default     = false
}
