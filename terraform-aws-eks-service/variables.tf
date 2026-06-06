variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
}

variable "service" {
  description = "Mapping of service name, namespace and their secrets"
  type = object({
    name                       = string
    additional_iam_policy_arns = optional(list(string), [])
    config_map                 = optional(map(any), {})
    hostnames                  = list(string)
    namespace                  = string
    secrets                    = optional(map(any), {})
    create_service_account     = optional(bool, false)
    service_account_name       = optional(string, "default")
  })
}

variable "route53_zone_id" {
  type        = string
  description = "The zone id for adding hostnames for services"
}

variable "alb_dns" {
  type        = string
  description = "The DNS of the ALB from K8s cluster"
}

variable "region" {
  type        = string
  description = "Region for getting ALB hosted zone ID"
}

variable "eks_oidc_provider" {
  description = "The OIDC provider of the EKS cluster"
  type = object({
    arn = string
    url = string
  })
}

variable "secret_env_var_name" {
  description = "To specify secret env var name"
  type        = string
  default     = null
}

variable "config_map_env_var_name" {
  description = "To specifiy config map env var name"
  type        = string
  default     = null
}

variable "create_kubernetes_namespace" {
  description = "To specify whether to create a namespace"
  type        = bool
  default     = false
}

variable "keda_role_arn" {
  description = "To set keda irsa role arn."
  type        = string
  default     = null
}

variable "assume_custom_roles" {
  description = "List of custom IAM assume role statements."
  type = list(object({
    sid         = optional(string, null)
    effect      = string
    actions     = list(string)
    type        = optional(string, null)
    identifiers = optional(list(string), null)
    resources   = optional(list(string), null)
    condition = optional(object({
      test     = string
      variable = string
      values   = list(string)
    }), null)
  }))
  default = []
}
