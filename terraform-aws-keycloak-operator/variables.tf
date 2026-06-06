# -----------------------------------------------------------------------------
# Basic Configuration
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name for the Keycloak deployment"
  type        = string
  default     = "keycloak"
}

variable "namespace" {
  description = "Kubernetes namespace for Keycloak"
  type        = string
  default     = "keycloak"
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Operator Configuration
# -----------------------------------------------------------------------------

variable "install_operator" {
  description = "Whether to install the Keycloak Operator (set false if already installed cluster-wide)"
  type        = bool
  default     = true
}

variable "operator_install_method" {
  description = "Method to install the operator: 'olm' (recommended, requires OLM on cluster) or 'manifest' (direct CRD/deployment)"
  type        = string
  default     = "olm"

  validation {
    condition     = contains(["olm", "manifest"], var.operator_install_method)
    error_message = "operator_install_method must be either 'olm' or 'manifest'"
  }
}

variable "operator_namespace" {
  description = "Namespace for the Keycloak Operator"
  type        = string
  default     = "keycloak-operator"
}

variable "create_operator_namespace" {
  description = "Create the operator namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "operator_version" {
  description = "Keycloak Operator version (used for manifest installation)"
  type        = string
  default     = "26.0.7"
}

# -----------------------------------------------------------------------------
# OLM Configuration (when operator_install_method = "olm")
# -----------------------------------------------------------------------------

variable "olm_channel" {
  description = "OLM subscription channel (fast, stable)"
  type        = string
  default     = "fast"
}

variable "olm_catalog_source" {
  description = "OLM catalog source name"
  type        = string
  default     = "operatorhubio-catalog"
}

variable "olm_catalog_source_namespace" {
  description = "OLM catalog source namespace"
  type        = string
  default     = "olm"
}

variable "olm_starting_csv" {
  description = "Specific CSV version to install (leave empty for latest)"
  type        = string
  default     = ""
}

variable "olm_install_plan_approval" {
  description = "OLM install plan approval mode (Automatic or Manual)"
  type        = string
  default     = "Automatic"

  validation {
    condition     = contains(["Automatic", "Manual"], var.olm_install_plan_approval)
    error_message = "olm_install_plan_approval must be either 'Automatic' or 'Manual'"
  }
}

# -----------------------------------------------------------------------------
# Keycloak Configuration
# -----------------------------------------------------------------------------

variable "keycloak_instances" {
  description = "Number of Keycloak replicas for high availability"
  type        = number
  default     = 2
}

variable "keycloak_image" {
  description = "Keycloak container image"
  type        = string
  default     = "quay.io/keycloak/keycloak:26.0.7"
}

variable "keycloak_image_pull_secrets" {
  description = "Image pull secrets for Keycloak container"
  type        = list(string)
  default     = []
}

variable "additional_options" {
  description = "Additional Keycloak server options (key-value pairs)"
  type        = map(string)
  default     = {}
}

variable "features_enabled" {
  description = "List of Keycloak features to enable"
  type        = list(string)
  default     = []
}

variable "features_disabled" {
  description = "List of Keycloak features to disable"
  type        = list(string)
  default     = []
}

variable "transaction_xa_enabled" {
  description = "Enable XA transactions"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Database Configuration (External PostgreSQL - Required)
# -----------------------------------------------------------------------------

variable "db_host" {
  description = "PostgreSQL database host"
  type        = string
}

variable "db_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "keycloak"
}

variable "db_schema" {
  description = "PostgreSQL database schema"
  type        = string
  default     = "public"
}

variable "db_username_secret" {
  description = "Kubernetes secret reference for database username"
  type = object({
    name = string
    key  = string
  })
}

variable "db_password_secret" {
  description = "Kubernetes secret reference for database password"
  type = object({
    name = string
    key  = string
  })
}

variable "db_pool_initial_size" {
  description = "Initial database connection pool size"
  type        = number
  default     = 5
}

variable "db_pool_min_size" {
  description = "Minimum database connection pool size"
  type        = number
  default     = 5
}

variable "db_pool_max_size" {
  description = "Maximum database connection pool size"
  type        = number
  default     = 20
}

# -----------------------------------------------------------------------------
# TLS Configuration
# -----------------------------------------------------------------------------

variable "http_enabled" {
  description = "Enable HTTP (non-TLS) access"
  type        = bool
  default     = true
}

variable "tls_secret_name" {
  description = "Kubernetes TLS secret name for HTTPS"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Hostname Configuration
# -----------------------------------------------------------------------------

variable "hostname" {
  description = "Keycloak hostname (required)"
  type        = string
}

variable "hostname_admin" {
  description = "Separate admin console hostname (optional)"
  type        = string
  default     = null
}

variable "hostname_strict" {
  description = "Enable strict hostname validation"
  type        = bool
  default     = true
}

variable "hostname_strict_backchannel" {
  description = "Enable strict hostname validation for backchannel"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Proxy Configuration
# -----------------------------------------------------------------------------

variable "proxy_headers" {
  description = "Proxy headers mode (xforwarded or forwarded)"
  type        = string
  default     = "xforwarded"
}

# -----------------------------------------------------------------------------
# Ingress Configuration
# -----------------------------------------------------------------------------

variable "create_ingress" {
  description = "Create AWS ALB Ingress for Keycloak"
  type        = bool
  default     = true
}

variable "ingress_class_name" {
  description = "Ingress class name"
  type        = string
  default     = "alb"
}

variable "ingress_group_name" {
  description = "ALB ingress group name for sharing ALB across services"
  type        = string
  default     = "external"
}

variable "ingress_scheme" {
  description = "ALB scheme (internet-facing or internal)"
  type        = string
  default     = "internet-facing"
}

variable "ingress_target_type" {
  description = "ALB target type (ip or instance)"
  type        = string
  default     = "ip"
}

variable "ingress_ssl_redirect" {
  description = "Enable SSL redirect on ALB"
  type        = bool
  default     = true
}

variable "ingress_certificate_arn" {
  description = "ACM certificate ARN for HTTPS (optional, uses auto-discovery if not set)"
  type        = string
  default     = null
}

variable "ingress_healthcheck_path" {
  description = "Health check path for ALB"
  type        = string
  default     = "/health"
}

variable "ingress_healthcheck_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 15
}

variable "ingress_healthcheck_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "ingress_healthcheck_healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 2
}

variable "ingress_healthcheck_unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3
}

variable "ingress_additional_annotations" {
  description = "Additional annotations for the ingress"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Resource Configuration
# -----------------------------------------------------------------------------

variable "resources" {
  description = "Resource requests and limits for Keycloak pods"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "500m"
      memory = "1Gi"
    }
    limits = {
      cpu    = "2"
      memory = "2Gi"
    }
  }
}

# -----------------------------------------------------------------------------
# Realm Import Configuration
# -----------------------------------------------------------------------------

variable "realm_imports" {
  description = "Map of realm configurations to import on startup"
  type        = map(any)
  default     = {}
}

# -----------------------------------------------------------------------------
# Unsupported Features (for advanced use cases)
# -----------------------------------------------------------------------------

variable "unsupported_pod_template" {
  description = "Raw pod template spec for unsupported configurations"
  type        = any
  default     = null
}
