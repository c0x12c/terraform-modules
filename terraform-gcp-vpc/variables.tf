variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "region" {
  description = "The region where the VPC and subnets will be created"
  type        = string
}

variable "application_subnet_cidr" {
  description = "CIDR block for the application subnet"
  type        = string
  default     = "10.10.0.0/20"
}

variable "services_subnet_cidr" {
  description = "CIDR block for the services secondary IP range"
  type        = string
  default     = "10.10.16.0/24"
}

variable "pods_subnet_cidr" {
  description = "CIDR block for the pods secondary IP range"
  type        = string
  default     = "10.10.32.0/20"
}

variable "data_subnet_cidr" {
  description = "CIDR block for the data subnet"
  type        = string
  default     = "10.20.10.0/24"
}

/**
NAT resource relating inputs
 */
variable "icmp_idle_timeout_sec" {
  description = "Timeout (in seconds) for ICMP connections. Defaults to 30s if not set. Changing this forces a new NAT to be created."
  type        = string
  default     = "30"
}

variable "min_ports_per_vm" {
  description = "Minimum number of ports allocated to a VM from this NAT config. Defaults to 64 if not set. Changing this forces a new NAT to be created."
  type        = string
  default     = "64"
}

variable "nat_ip_address_name" {
  description = "Defaults to 'cloud-nat-RANDOM_SUFFIX'. Changing this forces a new NAT to be created."
  type        = string
}

variable "nat_ip_allocate_option" {
  description = "Value inferred based on nat_ips. If present set to MANUAL_ONLY, otherwise AUTO_ONLY."
  type        = string
  default     = "MANUAL_ONLY"
}

variable "router_name" {
  description = "The name of the router in which this NAT will be configured. Changing this forces a new NAT to be created."
  type        = string
}

variable "router_asn" {
  description = "Router ASN, only if router is not passed in and is created by the module."
  type        = string
  default     = "64514"
}

variable "router_keepalive_interval" {
  description = "Router keepalive_interval, only if router is not passed in and is created by the module."
  type        = string
  default     = "20"
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "Defaults to ALL_SUBNETWORKS_ALL_IP_RANGES. How NAT should be configured per Subnetwork. Valid values include: ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, LIST_OF_SUBNETWORKS. Changing this forces a new NAT to be created."
  type        = string
  default     = "LIST_OF_SUBNETWORKS"
  validation {
    condition     = var.source_subnetwork_ip_ranges_to_nat == "ALL_SUBNETWORKS_ALL_IP_RANGES" || var.source_subnetwork_ip_ranges_to_nat == "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES" || var.source_subnetwork_ip_ranges_to_nat == "LIST_OF_SUBNETWORKS"
    error_message = "Sorry, value must be either 'ALL_SUBNETWORKS_ALL_IP_RANGES', 'ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES', or 'LIST_OF_SUBNETWORKS'."
  }
}

variable "tcp_established_idle_timeout_sec" {
  description = "Timeout (in seconds) for TCP established connections. Defaults to 1200s if not set. Changing this forces a new NAT to be created."
  type        = string
  default     = "1200"
}

variable "tcp_transitory_idle_timeout_sec" {
  description = "Timeout (in seconds) for TCP transitory connections. Defaults to 30s if not set. Changing this forces a new NAT to be created."
  type        = string
  default     = "30"
}

variable "udp_idle_timeout_sec" {
  description = "Timeout (in seconds) for UDP connections. Defaults to 30s if not set. Changing this forces a new NAT to be created."
  type        = string
  default     = "30"
}

variable "subnetworks" {
  description = "Specifies one or more subnetwork NAT configurations"
  type = list(object({
    name                    = string,
    source_ip_ranges_to_nat = list(string)
  }))
  default = []
}

variable "log_config_enable" {
  description = "Indicates whether or not to export logs"
  type        = bool
  default     = false
}

variable "log_config_filter" {
  description = "Specifies the desired filtering of logs on this NAT. Valid values are: 'ERRORS_ONLY', 'TRANSLATIONS_ONLY', 'ALL'"
  type        = string
  default     = "ALL"
  validation {
    condition     = var.log_config_filter == "ERRORS_ONLY" || var.log_config_filter == "TRANSLATIONS_ONLY" || var.log_config_filter == "ALL"
    error_message = "Sorry, value must be either 'ERRORS_ONLY', 'TRANSLATIONS_ONLY', or 'ALL'."
  }
}

variable "enable_endpoint_independent_mapping" {
  description = "Specifies if endpoint independent mapping is enabled."
  type        = bool
  default     = null
}
