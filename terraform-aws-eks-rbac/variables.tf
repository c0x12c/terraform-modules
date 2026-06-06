variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
}

variable "iam_path" {
  description = "If provided, all IAM roles will be created on this path."
  type        = string
  default     = "/"
}

variable "permissions_boundary" {
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
  type        = string
  default     = null
}

variable "profile_roles" {
  description = "Additional IAM roles existing from AWS will be added to the aws-auth configmap. These roles will link between Kubernetes Group permission and AWS IAM roles"
  type = list(object({
    name         = string
    privilege    = string
    profile_type = string
    role_arn     = string
  }))

  default = []
}

variable "cluster_roles" {
  description = "Additional IAM roles to be created and added to the aws-auth configmap. These roles will link between Kubernetes Cluster Roles and AWS IAM roles"
  type = list(object({
    name             = string
    privilege        = string
    trusted_role_arn = list(string)
  }))

  default = []
}


variable "namespace_roles" {
  description = "Additional IAM roles to be created and added to the aws-auth configmap. These roles will link between Kubernetes Namespace Roles and AWS IAM roles"
  type = list(object({
    namespace        = string
    privilege        = string
    trusted_role_arn = list(string)
  }))

  default = []
}

variable "aws_auth_users" {
  description = "Additional AWS IAM users to be added to the aws-auth configmap. These users will link between Kubernetes Users and AWS IAM users"
  default     = []
}

variable "aws_auth_accounts" {
  description = "Additional AWS accounts to be added to the aws-auth configmap. These accounts will link between Kubernetes Users and AWS IAM accounts"
  default     = []
}

variable "existing_aws_auth_data" {
  description = "Existing aws-auth data"
  type        = string
  default     = ""
}
