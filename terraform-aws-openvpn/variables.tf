variable "vpn_name" {
  type        = string
  description = "The name of the VPN."
  default     = "openvpn"
}

variable "instance_type" {
  type        = string
  description = "The type of the instance."
  default     = "t3.micro"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC."
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet."
}

variable "image_distro" {
  type        = string
  description = "The distribution of the image."
  default     = "debian-12-amd64"
}

variable "image_version" {
  type        = string
  description = "The version of the image."
  default     = "20240717-1811"
}

variable "disk_boot_size" {
  type        = number
  description = "The size of the boot disk in GB."
  default     = "10"
}

variable "domain_name" {
  type        = string
  description = "The domain name."
}

variable "organization" {
  type        = string
  description = "The name of the organization."
  default     = "Spartan"
}

variable "openvpn_fqdn" {
  type        = string
  description = "The fully qualified domain name of the OpenVPN."
  default     = ""
}

variable "extra_sg_ids" {
  type        = list(string)
  description = "A list of additional security group IDs."
  default     = []
}

variable "openvpn_ip_pool" {
  type        = string
  description = "The IP pool for OpenVPN clients."
  default     = "10.8.0.0"
}

variable "route_network_cidrs" {
  type        = list(string)
  description = "A list of network CIDRs to route."
  default     = ["10.0.0.0/8"]
}

variable "dns_server_cidrs" {
  type        = list(string)
  description = "A list of CIDRs where the DNS server IP is calculated as host index 2 of each CIDR."
  default     = []
}

variable "openvpn_auth_oauth2_version" {
  type        = string
  description = "The version of OpenVPN OAuth2 authentication plugin."
  default     = "1.22.4"
}

variable "oauth2_client_id" {
  type        = string
  description = "The OAuth2 client ID."
}

variable "oauth2_client_secret" {
  type        = string
  description = "The OAuth2 client secret."
}

variable "oauth2_provider" {
  type        = string
  description = "The OAuth2 provider."
  default     = "google"
}

variable "oauth2_issuer" {
  type        = string
  description = "The OAuth2 issuer."
  default     = "https://accounts.google.com"
}

variable "oauth2_validate_groups" {
  type        = string
  description = "The OAuth2 groups to validate, separated by comma"
  default     = null
}

variable "oauth2_validate_roles" {
  type        = string
  description = "The OAuth2 roles to validate, separated by comma. For GitHub provider, please note that team names must be slugified"
  default     = null
}

variable "create_management_key_pair" {
  type        = bool
  description = "Whether to create a management key pair."
  default     = true
}

variable "custom_cert_dns_names" {
  type        = list(string)
  description = "A list of custom DNS names to add to the certificate."
  default     = null
}

variable "create_egress_vpn_rule" {
  type        = bool
  description = "Whether to create an egress rule for the VPN."
  default     = true
}

variable "replace_instance_on_update" {
  type        = bool
  description = "Whether to replace the instance on update variables"
  default     = false
}

# For no change migrations
variable "init_script_callback_comment" {
  description = "The callback name for the OpenVPN server"
  type        = string
  default     = "Google Oauth 2.0 callback"
}

variable "http_tokens" {
  type        = string
  description = "The configuration for the instance metadata service tokens."
  default     = "optional"
}

variable "http_endpoint" {
  type        = string
  description = "The configuration for enabling or disabling the instance metadata service endpoint."
  default     = "enabled"
}

# Custom for migration

variable "key_name" {
  description = "The name of the key. If not set, the value of the key will default to the variable vpn_name."
  type        = string
  default     = null
}

variable "ec2_public_key" {
  description = "The existing value of ec2 public key. If not set, create and use `tls_private_key`."
  type        = string
  default     = null
}

variable "allow_remote_ssh_access" {
  description = "Whether to enable the SSH security group rule to allow remote access."
  type        = bool
  default     = false
}

variable "enabled_http_port" {
  description = "Whether to enable HTTP port through security group."
  type        = bool
  default     = true
}
