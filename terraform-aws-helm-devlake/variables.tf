variable "release_name" {
  description = "Helm release name."
  type        = string
  default     = "devlake"
}

variable "namespace" {
  description = "Kubernetes namespace to deploy DevLake into. Created by this module."
  type        = string
  default     = "devlake"
}

variable "create_namespace" {
  description = "Whether this module creates the namespace. Set false if it already exists."
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Version of the apache/devlake Helm chart."
  type        = string
}

variable "chart_repository" {
  description = "Helm repository hosting the DevLake chart."
  type        = string
  default     = "https://apache.github.io/devlake-helm-chart"
}

variable "chart_name" {
  description = "Helm chart name."
  type        = string
  default     = "devlake"
}

variable "image_tag" {
  description = "Image tag applied to the DevLake components. Empty uses the chart's default (matching the chart version)."
  type        = string
  default     = ""
}

variable "helm_release_timeout" {
  description = "Timeout in seconds for the Helm release."
  type        = number
  default     = 600
}

variable "enable_grafana" {
  description = "Deploy the bundled Grafana dashboard component."
  type        = bool
  default     = false
}

# --- Ingress ---------------------------------------------------------------

variable "ingress_enabled" {
  description = "Expose DevLake through an Ingress resource."
  type        = bool
  default     = true
}

variable "ingress_class_name" {
  description = "IngressClass name (e.g. `alb` for the AWS Load Balancer Controller)."
  type        = string
  default     = "alb"
}

variable "hostname" {
  description = "Hostname the DevLake UI is served on. Required when ingress is enabled."
  type        = string
  default     = ""
}

variable "ingress_annotations" {
  description = "Annotations applied to the Ingress resource (controller-specific)."
  type        = map(string)
  default     = {}
}

# --- Sizing ----------------------------------------------------------------

variable "lake_replica_count" {
  description = "Replica count for the lake (backend) deployment."
  type        = number
  default     = 1
}

variable "ui_replica_count" {
  description = "Replica count for the config-ui deployment."
  type        = number
  default     = 1
}

variable "lake_resources" {
  description = "Resource requests/limits for the lake (backend) container."
  type        = any
  default = {
    requests = { cpu = "250m", memory = "512Mi" }
    limits   = { cpu = "1", memory = "1Gi" }
  }
}

variable "ui_resources" {
  description = "Resource requests/limits for the config-ui container."
  type        = any
  default = {
    requests = { cpu = "100m", memory = "128Mi" }
    limits   = { cpu = "500m", memory = "256Mi" }
  }
}

# --- MySQL (in-cluster) ----------------------------------------------------

variable "mysql_use_external" {
  description = "Use an external MySQL server instead of the bundled in-cluster instance."
  type        = bool
  default     = false
}

variable "mysql_external_server" {
  description = "External MySQL host. Only used when mysql_use_external is true."
  type        = string
  default     = "127.0.0.1"
}

variable "mysql_external_port" {
  description = "External MySQL port. Only used when mysql_use_external is true."
  type        = number
  default     = 3306
}

variable "mysql_username" {
  description = "Username for the DevLake database."
  type        = string
  default     = "merico"
}

variable "mysql_database" {
  description = "Database name for DevLake."
  type        = string
  default     = "lake"
}

variable "mysql_storage_size" {
  description = "Persistent volume size for the in-cluster MySQL instance."
  type        = string
  default     = "20Gi"
}

variable "mysql_storage_class" {
  description = "Storage class for the in-cluster MySQL PVC. Empty uses the cluster default."
  type        = string
  default     = ""
}

variable "mysql_resources" {
  description = "Resource requests/limits for the in-cluster MySQL container."
  type        = any
  default = {
    requests = { cpu = "250m", memory = "512Mi" }
    limits   = { cpu = "1", memory = "1Gi" }
  }
}

# --- Secrets ---------------------------------------------------------------

variable "encryption_secret" {
  description = "DevLake ENCRYPTION_SECRET. If empty, the chart auto-generates one."
  type        = string
  default     = ""
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Admin password for the bundled Grafana. Empty leaves the chart default."
  type        = string
  default     = ""
  sensitive   = true
}

variable "mysql_password" {
  description = "Password for the DevLake database user."
  type        = string
  default     = ""
  sensitive   = true
}

variable "mysql_root_password" {
  description = "Root password for the in-cluster MySQL instance."
  type        = string
  default     = ""
  sensitive   = true
}
