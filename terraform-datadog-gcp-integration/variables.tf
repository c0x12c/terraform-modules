variable "datadog_account_id" {
  description = "The datadog account name to create."
  type        = string
}

variable "host_filters" {
  description = "A string used to filter the hosts sent from GCP to Datadog. Only hosts matching the specified tags will be included. Tags should be in the format 'key:value' and multiple tags can be separated by commas (e.g., 'environment:production,datadog:true')."
  type        = string
  default     = "datadog:true"
}

variable "datadog_roles" {
  description = "Datadog service account should have compute.viewer, monitoring.viewer, cloudasset.viewer, and browser roles (the browser role is only required in the default project of the service account)."
  type        = list(string)
  default = [
    "roles/compute.viewer",
    "roles/container.viewer",
    "roles/monitoring.viewer",
    "roles/cloudasset.viewer",
    "roles/browser"
  ]
}

variable "automute" {
  description = "Determines whether to automatically mute monitors related to this integration during a downtime. Set to 'true' to enable automatic muting and 'false' to disable it."
  type        = bool
  default     = true
}

variable "is_cspm_enabled" {
  description = "Indicates whether CSPM (Cloud Security Posture Management) is enabled in the Terraform configuration. Disable to save cost."
  type        = bool
  default     = false
}

# curl https://api.us5.datadoghq.com/api/v2/integration/gcp/accounts \
#     -H "DD-API-KEY: ${DD-API-KEY}" \
#     -H "DD-APPLICATION-KEY: ${DD-APPLICATION-KEY}"

variable "enabled_services" {
  description = "Values to enable GCP services in Datadog integration."
  type        = list(string)
  default = [
    "redis",
    "memcache",
    "memorystore",
    "cloudsql",
    "dbinsights",
    "kubernetes",
    "loadbalancing",
  ]
}