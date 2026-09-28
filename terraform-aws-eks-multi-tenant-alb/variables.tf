variable "name" {
  description = "Name of the ALB. Also used as the ingress group name and as the prefix of the ingress names."
  type        = string

  validation {
    condition     = length(var.name) <= 32 && can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.name))
    error_message = "name must be at most 32 characters (the ALB name limit) of lowercase letters, digits and '-'."
  }
}

variable "domain" {
  description = "Root domain of the tenant hosts, e.g. example.com. A host \"auth.acme\" is served at auth.acme.<domain>."
  type        = string
}

variable "zone_id" {
  description = "Route53 hosted zone ID for the certificate validation records and the host records."
  type        = string
}

variable "tenant_hosts" {
  description = "Hosts per tenant, as tenant => { service => host }. The host is relative to domain and must be <label>.<tenant>, so the tenant's *.<tenant>.<domain> certificate covers it. The service key must exist in services."
  type        = map(map(string))

  validation {
    condition     = length(var.tenant_hosts) > 0
    error_message = "Set at least one tenant: the HTTPS listener needs a certificate."
  }

  validation {
    condition = alltrue(flatten([
      for tenant, hosts in var.tenant_hosts : [
        for host in values(hosts) :
        can(regex("^[a-z0-9-]+$", tenant)) && endswith(host, ".${tenant}") && can(regex("^[a-z0-9-]+$", trimsuffix(host, ".${tenant}")))
      ]
    ]))
    error_message = "Each host must be <label>.<tenant> under its own tenant key, e.g. acme = { auth = \"auth.acme\" }."
  }
}

variable "services" {
  description = "Kubernetes backend for each service key used in tenant_hosts."
  type = map(object({
    namespace = string
    name      = string
    port      = number
  }))
}

variable "scheme" {
  description = "ALB scheme: internet-facing or internal."
  type        = string
  default     = "internet-facing"
}

variable "security_group_ids" {
  description = "Security groups for the ALB. When empty, the AWS Load Balancer Controller creates one."
  type        = list(string)
  default     = []
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs. Access logs are off when null."
  type        = string
  default     = null
}

variable "idle_timeout" {
  description = "ALB idle timeout in seconds."
  type        = number
  default     = 60
}

variable "deletion_protection" {
  description = "Enable ALB deletion protection. Set to false and apply before removing the module."
  type        = bool
  default     = true
}

variable "ssl_policy" {
  description = "SSL policy of the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "health_check_path" {
  description = "Target group health check path. ALB health checks send the target IP as Host, so this path must not require a tenant host."
  type        = string
  default     = "/health"
}

variable "ingress_namespace" {
  description = "Namespace of the ingress that creates the ALB and its default 404 rule."
  type        = string
  default     = "kube-system"
}

variable "tags" {
  description = "Tags applied to the ALB and the certificates."
  type        = map(string)
  default     = {}
}
