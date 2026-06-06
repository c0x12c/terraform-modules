variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
}

variable "aws_load_balancer_controller_name" {
  type        = string
  description = "Name of AWS load balancer controller name"
  default     = "aws-load-balancer-controller"
}

variable "aws_load_balancer_controller_chart_version" {
  type        = string
  description = "Helm chart version of AWS load balancer controller"
  default     = "1.12.0"
}

variable "namespace" {
  type        = string
  description = "Namespace of the aws load balancer"
  default     = "kube-system"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC that the resources reside in."
}

variable "public_subnet" {
  type        = list(string)
  description = "List public subnet of cluster for creating aws external load balancer"
}

variable "private_subnet" {
  type        = list(string)
  description = "List private subnet of cluster for creating aws internal load balancer"
}

variable "certificate_arn" {
  type        = list(string)
  description = "Certificate arn for aws load balancer controller"
}

variable "ssl_policy" {
  type        = string
  description = "SSL policy for AWS Load Balancer"
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "region" {
  type        = string
  description = "Region where the resources will be created."
  default     = null
}

variable "idle_timeout" {
  type        = string
  description = "The idle timeout of load balancer."
  default     = "60"
}

variable "oidc_provider" {
  type = object({
    arn = string
    url = string
  })
  description = "The OIDC provider which are realted to the cluster."
}

variable "external_group_name" {
  default     = "external"
  description = "Group name of external aws load balancer"
}

variable "enable_internal_alb" {
  default     = false
  description = "Enable internal aws load balancer"
}

variable "internal_group_name" {
  default     = "internal"
  description = "Group name of internal aws load balancer"
}

variable "wafv2_arn" {
  type        = string
  description = "Set the WAFv2 to enable ALB and WAFv2 association"
  default     = null
}

variable "node_selector" {
  description = "Node selector for the AWS Load Balancer Controller"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for the AWS Load Balancer Controller"
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = optional(string)
  }))
  default = []
}

variable "external_default_service" {
  description = "Default external service for the AWS Load Balancer Controller"
  type = object({
    name = string
    port = number
  })
  default = null
}

variable "internal_default_service" {
  description = "Default internal service for the AWS Load Balancer Controller"
  type = object({
    name = string
    port = number
  })
  default = null
}
