variable "namespace" {
  description = "The Namespace of the services."
  type        = string
  default     = "keycloak"
}
variable "helm_release_name" {
  description = "The Helm release of the services."
  type        = string
  default     = "keycloak"
}

variable "helm_chart_version" {
  default     = "24.4.13"
  type        = string
  description = "The chart version of keycloak"
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "Determines whether a new namespace should be created. Set to 'true' to create the namespace; otherwise, set to 'false' to use an existing namespace."
}

variable "keycloak_cpu" {
  type        = string
  description = "Keycloak cpu"
  default     = "450m"
}

variable "keycloak_memory" {
  type        = string
  description = "Keycloak memory"
  default     = "1024Mi"
}

variable "create_postgresql" {
  type    = bool
  default = true
}

variable "postgresql_db_name" {
  type        = string
  description = "Name of the database"
  default     = "keycloak"
}

variable "postgresql_username" {
  type        = string
  description = "Username for the database"
  default     = "keycloak"
}

variable "postgresql_password" {
  type        = string
  description = "Password for the database"
  default     = null
}

variable "postgresql_host" {
  type        = string
  description = "Host for the external database"
  default     = ""
}

variable "storage_class_name" {
  type        = string
  description = "Storage class name"
  default     = ""
}

variable "create_ingress" {
  type        = bool
  description = "Whether to create the ingress"
  default     = true
}

variable "ingress_class_name" {
  type        = string
  description = "Ingress class name"
  default     = "alb"
}

variable "ingress_group_name" {
  type        = string
  description = "Ingress group name"
  default     = "external"
}

variable "ingress_hostname" {
  type        = string
  description = "Hostname for the ingress"
  default     = ""
}

variable "node_selector" {
  description = "Node selector for the keycloak"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for the keycloak"
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = optional(string)
  }))
  default = []
}
