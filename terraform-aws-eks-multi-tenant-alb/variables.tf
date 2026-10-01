variable "name" {
  description = "Name of the ALB. Also used as the ingress group name and as the prefix of the ingress names."
  type        = string

  validation {
    condition     = length(var.name) <= 32 && can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.name))
    error_message = "name must be at most 32 characters (the ALB name limit) of lowercase letters, digits and '-'."
  }
}

variable "domain" {
  description = "Root domain of the hosts, e.g. example.com. Every host is host_template followed by .<domain>."
  type        = string
}

variable "tenants" {
  description = "Tenant names. Each tenant gets one host per service, built from host_template. \"*\" is a wildcard tenant: one host rule, certificate and DNS record per service serve every tenant. It needs {tenant} as the leftmost label of host_template."
  type        = set(string)

  validation {
    condition     = length(var.tenants) > 0
    error_message = "Set at least one tenant."
  }

  validation {
    condition     = alltrue([for tenant in var.tenants : tenant == "*" || can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", tenant))])
    error_message = "Each tenant must be a DNS label (lowercase letters, digits and '-') or \"*\"."
  }
}

variable "host_template" {
  description = "Host of each route, relative to domain. {tenant} and {service} are replaced: \"{service}.{tenant}\" serves auth.acme.<domain>, \"{tenant}.{service}\" serves acme.auth.<domain>."
  type        = string
  default     = "{service}.{tenant}"

  validation {
    condition     = strcontains(var.host_template, "{tenant}") && strcontains(var.host_template, "{service}")
    error_message = "host_template must contain {tenant} and {service}, so that every route gets its own host."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+(\\.[a-z0-9-]+)*$", replace(replace(var.host_template, "{tenant}", "t"), "{service}", "s")))
    error_message = "host_template must be dot-separated DNS labels relative to domain, e.g. \"{service}.{tenant}\"."
  }
}

variable "services" {
  description = "Kubernetes backend of each service. The key is the {service} value in host_template. health_check_path overrides the module-wide health_check_path for that service."
  type = map(object({
    namespace         = string
    name              = string
    port              = number
    health_check_path = optional(string)
  }))

  validation {
    condition     = length(var.services) > 0
    error_message = "Set at least one service."
  }

  validation {
    condition     = alltrue([for service in keys(var.services) : can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", service))])
    error_message = "Each service key must be a DNS label (lowercase letters, digits and '-'), because it becomes part of the host."
  }
}

variable "zone_id" {
  description = "Route53 hosted zone ID for certificate validation and host records. Ignored when create_hosted_zone is true (the created sub-zone is used instead). Required when create_certificates or create_dns_records is true and create_hosted_zone is false."
  type        = string
  default     = null
}

variable "create_hosted_zone" {
  description = "Create one Route53 sub-zone per tenant, named <tenant>.<domain>. Certificate validation and host records then land in that zone. Set parent_zone_id to also write the NS delegation into the parent zone. Only valid with host_template \"{service}.{tenant}\", so the sub-zone apex is the tenant apex."
  type        = bool
  default     = false
}

variable "parent_zone_id" {
  description = "Route53 hosted zone ID of the parent domain. When set together with create_hosted_zone, the module writes an NS record for each tenant sub-zone into this zone, so the sub-zone is reachable. Leave null when delegation is handled elsewhere."
  type        = string
  default     = null
}

variable "hosted_zone_ns_ttl" {
  description = "TTL in seconds of the NS delegation records written into parent_zone_id."
  type        = number
  default     = 172800
}

variable "create_certificates" {
  description = "Create one DNS-validated ACM certificate per parent domain of the hosts, e.g. *.acme.<domain> for auth.acme.<domain>. See include_apex_in_certificates for the apex SAN. Set to false to use only certificate_arns."
  type        = bool
  default     = true
}

variable "include_apex_in_certificates" {
  description = "Add the apex of each certificate's parent domain as a SAN, e.g. acme.<domain> alongside *.acme.<domain>. Needed when the apex itself serves traffic (e.g. the webapp host). Skipped automatically when the parent domain is the module's root domain."
  type        = bool
  default     = true
}

variable "create_cloudfront_cert" {
  description = "Also issue the same-SAN certificates in us-east-1, for CloudFront to consume. Requires an aws.us_east_1 provider alias passed to the module. Output as cloudfront_certificate_arns."
  type        = bool
  default     = false
}

variable "certificate_arns" {
  description = "ARNs of existing ACM certificates to attach to the HTTPS listener, in addition to the created ones. Use this when a certificate you already have covers the hosts."
  type        = list(string)
  default     = []
}

variable "create_dns_records" {
  description = "Create a Route53 A alias record to the ALB for each service host. Set to false when DNS is managed elsewhere."
  type        = bool
  default     = true
}

variable "create_service_ingresses" {
  description = "Create one Kubernetes ingress per service with one host rule per tenant. Set to false when the service's Helm chart already renders the ingress with the tenant hosts (it must join the ALB with annotation alb.ingress.kubernetes.io/group.name = var.name)."
  type        = bool
  default     = false
}

variable "webapp_alias_target" {
  description = "Alias target for the tenant apex record <tenant>.<domain>, typically a CloudFront distribution. When set, one A alias record is created per tenant into the effective zone (sub-zone when create_hosted_zone is true, else zone_id). Leave null to skip."
  type = object({
    name    = string
    zone_id = string
  })
  default = null
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

variable "wafv2_arn" {
  description = "ARN of a WAFv2 web ACL to associate with the ALB. No WAF when null."
  type        = string
  default     = null
}

variable "health_check_path" {
  description = "Target group health check path for every service that does not set its own. ALB health checks send the target IP as Host, so this path must not require a tenant host."
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
