variable "datadog_agent_cluster_role_name" {
  type        = string
  description = "Name of the ClusterRole to create in order to configure Datadog Agents"
}

variable "custom_service_accounts" {
  type        = map(list(string))
  description = <<EOF
Map of service account names for binding with Datadog.
Each key represents a namespace, and the value is a list of service account names.
  {
    namespace = ["service-account1", "service-account2]
  }
EOF
  default     = {}
}

variable "default_service_account" {
  type        = string
  description = "Default service account name for binding with Datadog"
  default     = "default"
}

variable "create_datadog_agent_cluster_role" {
  description = "Controls whether to create the Datadog Agent ClusterRole"
  type        = bool
  default     = true
}

variable "enable_default_service_accounts" {
  description = "Enable or disable binding of default service accounts"
  type        = bool
  default     = true
}
