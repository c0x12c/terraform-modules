variable "name" {
  description = "Name of the Redpanda cluster. Used for the Kubernetes resources and as part of every AWS resource name."
  type        = string
  default     = "redpanda"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,30}[a-z0-9])?$", var.name))
    error_message = "name must be a lowercase DNS label of at most 32 characters."
  }
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster Redpanda is installed into."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the operator and the cluster."
  type        = string
  default     = "redpanda"
}

variable "create_namespace" {
  description = "Create the namespace. Set to false when it already exists."
  type        = bool
  default     = true
}

variable "operator" {
  description = "Redpanda Operator release. Set install to false when an operator already watches this namespace."
  type = object({
    install       = optional(bool, true)
    chart_version = optional(string, "v26.1.9")
  })
  default = {}
}

variable "redpanda_version" {
  description = "Redpanda image tag."
  type        = string
  default     = "v26.2.2"
}

variable "size" {
  description = <<-EOT
    Sizing profile, cheapest first:
    small  - 3 brokers, 1 core, 2.5Gi each, EBS volumes, requires a dedicated EC2 pool;
    medium - 3 brokers on dedicated i4g.xlarge, local NVMe;
    large  - 3 brokers on dedicated i4g.2xlarge, local NVMe.
    Any field of var.brokers overrides the profile.
  EOT
  type        = string
  default     = "small"

  validation {
    condition     = contains(["small", "medium", "large"], var.size)
    error_message = "size must be one of small, medium, large."
  }
}

variable "brokers" {
  description = "Per-field overrides of the sizing profile. replicas scales out; cpu_cores and memory scale up."
  type = object({
    replicas       = optional(number)
    cpu_cores      = optional(number)
    memory         = optional(string)
    storage_type   = optional(string) # ebs | local_nvme
    storage_size   = optional(string) # ebs only
    storage_class  = optional(string) # ebs only, null = cluster default
    instance_types = optional(list(string))
  })
  default = {}

  validation {
    condition     = var.brokers.storage_type == null || contains(["ebs", "local_nvme"], coalesce(var.brokers.storage_type, "ebs"))
    error_message = "brokers.storage_type must be ebs or local_nvme."
  }

  validation {
    condition     = var.brokers.replicas == null || coalesce(var.brokers.replicas, 3) >= 3
    error_message = "brokers.replicas must be at least 3 for replication factor 3."
  }
}

variable "node_group" {
  description = <<-EOT
    Dedicated broker nodes, one managed node group per subnet (one subnet per AZ).
    Required for local_nvme storage, since the module's user data prepares the instance store.
    Nodes are tainted dedicated=<name>:NoSchedule so nothing else lands on them.
    On Fargate-first clusters create this group or provide an external tainted EC2 pool.
    labels and taint override the default selector and NoSchedule toleration for either pool.
  EOT
  type = object({
    create             = optional(bool, false)
    subnet_ids         = optional(list(string), [])
    kubernetes_version = optional(string)
    root_volume_size   = optional(number, 50)
    labels             = optional(map(string))
    taint = optional(object({
      key   = string
      value = string
    }))
  })
  default = {}

  validation {
    condition     = !var.node_group.create || length(var.node_group.subnet_ids) >= 1
    error_message = "node_group.subnet_ids needs at least one subnet when node_group.create is true; use three, one per AZ."
  }
}

variable "tls_enabled" {
  description = "TLS on the Kafka, Admin and Schema Registry listeners. Needs cert-manager in the cluster."
  type        = bool
  default     = false
}

variable "rack_awareness" {
  description = "Spread replicas across zones using the topology.kubernetes.io/zone node label. Also enables follower fetching for clients that set client.rack."
  type        = bool
  default     = true
}

variable "tiered_storage" {
  description = "Offload closed segments to S3. Needs an Enterprise licence and oidc_provider. local_retention_bytes caps what stays on broker disk per partition."
  type = object({
    enabled               = optional(bool, false)
    bucket_name           = optional(string) # null = create one
    force_destroy         = optional(bool, false)
    local_retention_bytes = optional(number)
  })
  default = {}
}

variable "oidc_provider" {
  description = "The EKS cluster's OIDC provider, for the IRSA role that tiered storage uses."
  type = object({
    arn = string
    url = string
  })
  default = null
}

variable "enterprise_license_secret" {
  description = "Existing Secret holding the Redpanda Enterprise licence. Needed for tiered storage and Console authentication."
  type = object({
    name = string
    key  = string
  })
  default = null
}

variable "console_enabled" {
  description = "Deploy Redpanda Console. Off by default: without an Enterprise licence it has no per-user login, so it is an operator tool only."
  type        = bool
  default     = false
}

variable "cluster_config" {
  description = "Extra Redpanda cluster properties, merged over the module defaults."
  type        = map(any)
  default     = {}
}

variable "tenants" {
  description = <<-EOT
    Tenants keyed by name. Each gets a SCRAM user, ACLs limited to topics, groups and
    transactional ids prefixed "<tenant>.", and the listed topics, created as "<tenant>.<topic>".
    Tenants cannot create topics themselves. Byte rates are per broker, in bytes per second.
  EOT
  type = map(object({
    topics = optional(map(object({
      partitions         = optional(number, 3)
      replication_factor = optional(number, 3)
      config             = optional(map(string), {})
    })), {})
    producer_byte_rate = optional(number)
    consumer_byte_rate = optional(number)
    transactions       = optional(bool, false)
    extra_acls         = optional(any, [])
  }))
  default = {}

  validation {
    condition     = alltrue([for k in keys(var.tenants) : can(regex("^[a-z]([a-z0-9-]*[a-z0-9])?$", k))])
    error_message = "Tenant names must be lowercase DNS labels starting with a letter, without dots."
  }

  validation {
    condition = alltrue(flatten([for t in values(var.tenants) : [
      for k in keys(t.topics) : can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", k))
    ]]))
    error_message = "Topic names must be lowercase DNS labels; they become Kubernetes object names."
  }
}

variable "tags" {
  description = "Tags for every AWS resource."
  type        = map(string)
  default     = {}
}
