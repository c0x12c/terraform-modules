variable "argocd_namespace" {
  description = "Namespace to install Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Version of the Argo CD Helm chart"
  type        = string
  default     = "7.8.26"
}

variable "chart_url" {
  description = "URL of the Argo CD Helm chart"
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
}

variable "repositories" {
  description = "To connect to repository by using Credentials Template, which is currently using Github App"
  type        = list(string)
  default     = []
}

variable "ingress_group_name" {
  description = "Ingress group name for Argo CD"
  type        = string
  default     = "external"
}

variable "ingress_class_name" {
  description = "Ingress class name for Argo CD"
  type        = string
  default     = "alb"
}

variable "handle_tls" {
  description = "If ArgoCD should handle TLS itself"
  type        = bool
  default     = false
}

variable "server_side_diff" {
  description = "Enable server side diff"
  type        = bool
  default     = true
}

# Enabled in-cluster
variable "enabled_managed_in_cluster" {
  description = "Enable in_cluster manage to rename in_cluster"
  type        = bool
  default     = true
}

variable "in_cluster_name" {
  description = "To customize the in_cluster name for easier management (only `enabled_managed_in_cluster = true`)"
  type        = string
  default     = "in-cluster"
}

variable "enabled_aws_management_role" {
  description = "Enable the AWS management role for cross cluster management"
  type        = bool
  default     = false
}

variable "aws_management_role" {
  description = "AWS management role configuration, only required if enabled_aws_management_role is true"
  type = object({
    eks_oidc_provider_arn = string
    role_name             = string
    eks_oidc_provider_url = string
  })

  # Only required if enabled_aws_management_role is true
  default = null
}

variable "github_app" {
  description = "GitHub App configuration to use for Argo CD"
  type = object({
    secret_name     = string
    app_id          = number
    installation_id = number
    private_key     = string
    organization    = string
  })
  sensitive = true
}

variable "oidc_github_client_id" {
  description = "GitHub App Client ID for OIDC"
  type        = string
}

variable "oidc_github_client_secret" {
  description = "GitHub App Client Secret for OIDC"
  type        = string
  sensitive   = true
}

variable "oidc_github_organization" {
  description = "GitHub organization to restrict access to"
  type        = string
}

variable "rbac_policies" {
  description = "List of RBAC policies to apply"
  type        = list(string)
  default     = []
}

variable "external_clusters" {
  description = "Maps of external cluster that want to connect"
  type = map(object({
    assume_role       = optional(string, "")
    server            = string
    labels            = optional(map(any), {})
    annotations       = optional(map(any), {})
    namespace         = optional(string, "")
    cluster_resources = optional(bool, false)
    config = object({
      aws_auth_config = object({
        cluster_name = string
        role_arn     = string
      })
      tls_client_config = object({
        insecure = optional(bool, false)
        ca_data  = string
      })
    })
  }))
  default = {}
}

variable "slack_token" {
  description = "The token to authenticate to slack, which will help application push notification to slack"
  type        = string
  default     = ""
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name for ArgoCD"
  type        = string
}

variable "sub_domain" {
  description = "Sub domain for ArgoCD"
  type        = string
  default     = "argocd"
}

# Managed Node
variable "node_selector" {
  description = "Node selector for the ingress controller"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for the ingress controller"
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = optional(string)
  }))
  default = []
}

# Dex Config
variable "issuer_url" {
  description = "The issuer URL should be where Dex talks to the OIDC provider"
  type        = string
  default     = "http://argocd-dex-server:5556"
}

variable "create_route53_record" {
  description = "Determines whether or not to create a route53 record for the ingress or not"
  type        = bool
  default     = false
}

variable "alb_zone_id" {
  description = "The Route53 zone ID to create the record in"
  type        = string
  default     = null
}

variable "alb_cname" {
  description = "Alias for the ALB (required when alb_zone_id is not null)"
  type        = string
  default     = null
}
