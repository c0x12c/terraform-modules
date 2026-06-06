locals {
  default_fqdn = "${var.vpn_name}.${var.domain_name}"
  openvpn_fqdn = var.openvpn_fqdn != "" ? var.openvpn_fqdn : local.default_fqdn
}

variable "vpn_name" {
  description = "The name of the VPN."
  default     = "openvpn"
}

variable "machine_type" {
  description = "The type of the instance."
  default     = "e2-micro"
}

variable "vpc_name" {
  description = "The name of the VPC."
}

variable "vpc_subnet" {
  description = "The subnet of the VPN."
}

variable "image_distro" {
  description = "The distribution of the image."
  default     = "debian-12-bookworm"
}

variable "image_version" {
  description = "The version of the image."
  default     = "v20240415"
}

variable "disk_boot_size" {
  description = "The size of the boot disk in GB."
  default     = "10"
}

variable "network_tags" {
  description = "A list of network tags to attach to the instance"
  default     = []
}

variable "region" {
  description = "The region that object should be created in."
  default     = "us-west1"
}

variable "zone" {
  description = "The zone that object should be created in"
  default     = "us-west1-a"
}

variable "domain_name" {
  description = "The name of domain"
}

variable "organization" {
  description = "The name of the organization."
  type        = string
  default     = "Spartan"
}

variable "openvpn_fqdn" {
  description = "The fully qualified domain name of the OpenVPN."
  default     = ""
}

variable "openvpn_ip_pool" {
  default     = "10.8.0.0"
  type        = string
  description = "The IP pool for OpenVPN clients."
}

variable "route_network_cidrs" {
  description = "A list of network CIDRs to route."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "openvpn_auth_oauth2_version" {
  description = "The version of OpenVPN OAuth2 authentication plugin."
  type        = string
  default     = "1.22.4"
}

variable "oauth2_client_id" {
  description = "The OAuth2 client ID."
  type        = string
}

variable "oauth2_client_secret" {
  description = "The OAuth2 client secret."
  type        = string
}
