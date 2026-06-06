variable "argocd_namespace" {
  description = "Namespace of Argo CD"
  type        = string
  default     = "argocd"
}

variable "path" {
  description = "path"
  type        = string
  default     = "dev"
}

variable "github_organization" {
  description = "GitHub Organization"
  type        = string
}

variable "custom_group_roles" {
  description = <<EOT
The project group roles define permissions in the format: 'applications, {roles}'.
- 'applications' specifies the scope (e.g., 'applications' or a specific app).
- '{roles}' can be specific roles (e.g., 'admin', 'viewer') or '*' for all roles.
Example:
  "spartan-P00001-iaas" = ["applications, *",]
  "spartan-P00001-member"  = [
      "applications, *"
      "applications, get"
    ]
EOT
  type        = map(list(string))
  default     = {}
}

variable "predefined_group_rules" {
  description = "To add groups to predefined rule by admin, member, and viewer group respectively with full permission, write and read permission, and read-only permission"
  type = object({
    admin  = optional(list(string), [])
    member = optional(list(string), [])
    viewer = optional(list(string), [])
  })
  default = {}
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "project_name" {
  type = string
}

variable "repo_url" {
  description = "ArgoCD Centralized Repository"
  type        = string
}

# Sync policy
variable "sync_policy" {
  description = "value"
  type = object({
    automated = optional(object({
      prune    = optional(bool)
      selfHeal = optional(bool)
    }))

    syncOptions = optional(list(string))

    retry = optional(object({
      limit = optional(number)
    }))
  })
  default = {}
}

variable "target_revision" {
  description = "Target Revision for deployment"
  type        = string
  default     = "HEAD"
}

variable "description" {
  type = string
}

variable "destinations" {
  type = list(object({
    name      = optional(string, null)
    server    = optional(string, null)
    namespace = string
  }))
}