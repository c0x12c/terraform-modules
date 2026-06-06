variable "cluster_name" {
  description = "The name of the GKE cluster will be created."
  type        = string
}
variable "project_id" {
  description = "The ID of the project where the GKE will be created."
  type        = string
}

variable "region" {
  description = "Region where the resources will be created."
  type        = string
}

variable "environment" {
  description = "Environment where the resources will be created."
  type        = string
}

variable "network" {
  description = "The name or self_link of the Google Compute Engine network to which the cluster is connected. For Shared VPC, set this to the self link of the shared network."
  type        = string
}

variable "subnetwork" {
  description = "The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched."
  type        = string
}

variable "enable_private_endpoint" {
  description = "When true, the cluster's private endpoint is used as the cluster endpoint and access through the public endpoint is disabled. When false, either endpoint can be used. This field only applies to private clusters, when enable_private_nodes is true."
  type        = bool
  default     = false
}

variable "enable_private_nodes" {
  description = "Enables the private cluster feature, creating a private endpoint on the cluster. In a private cluster, nodes only have RFC 1918 private addresses and communicate with the master's private endpoint via private networking."
  type        = bool
  default     = true
}

variable "enable_vertical_pod_autoscaling" {
  description = "Enable vertical pod autoscaling controlled by the cluster."
  type        = bool
  default     = true
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet. See Private Cluster Limitations for more details. This field only applies to private clusters, when enable_private_nodes is true."
  type        = string
  default     = "172.23.0.0/28"
}

variable "master_authorized_networks_config" {
  description = "List of CIDR blocks to allow access to the Kubernetes master. External network that can access Kubernetes master through HTTPS. Must be specified in CIDR notation."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "labels" {
  description = "The resource labels to represent user provided metadata."
  type        = map(string)
  default     = null
}

variable "daily_maintenance_window_start_time" {
  description = "Time window specified for daily maintenance operations."
  type        = string
  default     = "09:00"
}

variable "release_channel" {
  description = "The selected release channel. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#channel."
  type        = string
  default     = "STABLE"
}

variable "min_master_version" {
  description = "The minimum version of the master. GKE will auto-update the master to new versions, so this does not guarantee the current master version--use the read-only master_version field to obtain that. If unset, the cluster's version will be set by GKE to the version of the most recent official release (which is not necessarily the latest version)."
  type        = string
  default     = "1.30.5-gke.1014003"
}

variable "maintenance_start_time" {
  description = "Start time for the maintenance window (format: YYYY-MM-DDTHH:MM:SSZ)."
  type        = string
  default     = "2024-11-25T00:00:00Z"
}

variable "maintenance_end_time" {
  description = "End time for the maintenance window (format: YYYY-MM-DDTHH:MM:SSZ)."
  type        = string
  default     = "2024-11-25T04:00:00Z"
}

variable "maintenance_recurrence" {
  description = "Recurrence rule for maintenance. Occurs on weekdays."
  type        = string
  default     = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range to be used for the Kubernetes pods."
  type        = string
  default     = "pods"
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range to be used for the Kubernetes services."
  type        = string
  default     = "services"
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the cluster. Unless this field is set to false in Terraform state, a terraform destroy or terraform apply that would delete the cluster will fail."
  type        = bool
  default     = true
}

variable "enable_cost_management_config" {
  description = "Whether or not to enable GCP Cost Allocation feature."
  type        = bool
  default     = false
}
