variable "chart_version" {
  description = "The version of the Neo4J Helm chart being deployed."
  type        = string
  default     = "0.2.0"
}

variable "helm_release_name" {
  description = "The name of the Helm release for the Neo4J deployment."
  type        = string
  default     = "neo4j"
}

variable "neo4j_password" {
  type        = string
  description = "The password for the Neo4J database."
  default     = null
}

variable "namespace" {
  description = "The Kubernetes namespace where Neo4J will be installed. Defaults to 'neo4j'."
  type        = string
  default     = "neo4j"
}

variable "efs_id" {
  type        = string
  description = "The ID of the EFS (Elastic File System) used for mounting the Neo4J home directory."
}

variable "efs_neo4j_access_point" {
  type        = string
  description = "The specific access point within the EFS for the Neo4J home directory."
  default     = "/neo4j-home"
}

variable "efs_storage_class_name" {
  type        = string
  description = "The storage class name used for Persistent Volumes with EFS."
  default     = "efs"
}

variable "disk_size" {
  type        = string
  description = "The size of the disk to be allocated for Neo4J storage."
  default     = "8Gi"
}

variable "neo4j_fqdn" {
  description = "FQDN of Neo4j service"
  type        = string
  default     = ""
}

variable "domain" {
  description = "The root domain of project"
  type        = string
}

variable "neo4j_dns_name" {
  description = "The Neo4j DNS name"
  type        = string
  default     = "neo4j"
}

variable "ingress_group_name" {
  description = "The ingress group name of Neo4j ingress"
  type        = string
  default     = "external"
}

variable "ingress_class_name" {
  description = "The ingress class name of Neo4j ingress"
  type        = string
  default     = "alb"
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "Determines whether a new namespace should be created. Set to 'true' to create the namespace; otherwise, set to 'false' to use an existing namespace."
}

variable "force_update" {
  type        = bool
  default     = true
  description = "Indicates whether updates should be forced, even if they might result in resource recreation. Set to 'true' to force updates."
}

variable "neo4j_cpu" {
  description = "The CPU request and limit for Neo4j"
  type        = string
  default     = "1950m"
}

variable "neo4j_memory" {
  description = "The memory request and limit for Neo4j"
  type        = string
  default     = "3.5Gi"
}

variable "neo4j_plugins" {
  type        = list(string)
  description = "A list of URLs pointing to the Neo4J plugins to be installed."
  default     = []
}

variable "neo4j_plugins_dir" {
  type        = string
  description = "The directory where Neo4J plugins will be stored."
  default     = "/opt/bitnami/neo4j/plugins"
}

variable "custom_neo4j_config" {
  type        = string
  description = "Custom configuration settings for Neo4J."
  default     = null
}

variable "neo4j_procedures" {
  type        = string
  default     = "gds.*,apoc.*"
  description = "A comma-separated list of Neo4j procedures and functions to allow."
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for neo4j"
  default     = {}
}

variable "tolerations" {
  type        = list(map(string))
  description = "Tolerations for neo4j"
  default     = []
}
