#----------------------------------------------------------------
# EC2 Instance
#----------------------------------------------------------------
variable "name" {
  description = "Name to be used on EC2 instance created"
  type        = string
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly"
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "AZ to start the instance in"
  type        = string
  default     = null
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host"
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated", "host"], var.tenancy)
    error_message = "Invalid tenancy value. Must be one of: default, dedicated, host."
  }
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = true
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance"
  type        = bool
  default     = true
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = bool
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances"
  type        = string
  default     = "stop"

  validation {
    condition     = contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "Invalid shutdown behavior. Must be either 'stop' or 'terminate'."
  }
}

#----------------------------------------------------------------
# Block Devices
#----------------------------------------------------------------
variable "root_block_device" {
  description = <<-EOD
  Customize details about the root block device of the instance.
  Available options:
  - volume_type: The type of volume (gp2, gp3, io1, io2, st1, sc1)
  - volume_size: The size of the volume in gigabytes
  - iops: The amount of provisioned IOPS (only for io1, io2, gp3)
  - throughput: The throughput to provision for gp3 volumes
  - encrypted: Whether to enable volume encryption
  - kms_key_id: The ARN of the AWS KMS key to use for encryption
  - delete_on_termination: Whether the volume should be destroyed on instance termination
  - tags: A map of tags to assign to the device
  EOD
  type        = any
  default     = null
}

variable "ebs_block_devices" {
  description = <<-EOD
  Additional EBS block devices to attach to the instance.
  Each block device should include:
  - device_name: The name of the device to mount
  - volume_type: The type of volume (gp2, gp3, io1, io2, st1, sc1)
  - volume_size: The size of the volume in gigabytes
  - iops: The amount of provisioned IOPS (only for io1, io2, gp3)
  - throughput: The throughput to provision for gp3 volumes
  - encrypted: Whether to enable volume encryption
  - kms_key_id: The ARN of the AWS KMS key to use for encryption
  - snapshot_id: The Snapshot ID to mount
  - delete_on_termination: Whether the volume should be destroyed on instance termination
  - tags: A map of tags to assign to the device
  EOD
  type        = list(any)
  default     = []
}

#----------------------------------------------------------------
# Metadata Options
#----------------------------------------------------------------
variable "metadata_options" {
  description = <<-EOD
  Customize the metadata options of the instance.
  Available options:
  - http_endpoint: Whether the metadata service is available (enabled or disabled)
  - http_tokens: Whether or not the metadata service requires session tokens (optional or required)
  - http_put_response_hop_limit: The desired HTTP PUT response hop limit for instance metadata requests
  - instance_metadata_tags: Enables or disables access to instance tags from the instance metadata service
  EOD
  type        = any
  default     = null
}

#----------------------------------------------------------------
# Network Interfaces
#----------------------------------------------------------------
variable "network_interfaces" {
  description = <<-EOD
  Customize network interfaces to be attached at instance boot time.
  Each network interface should include:
  - device_index: The integer index of the network interface attachment
  - network_interface_id: The ID of the network interface to attach
  - delete_on_termination: Whether or not to delete the network interface on instance termination
  EOD
  type        = list(any)
  default     = []
}

#----------------------------------------------------------------
# Elastic IP
#----------------------------------------------------------------
variable "create_eip" {
  description = "Whether to create an Elastic IP for the instance"
  type        = bool
  default     = false
}

variable "eip_tags" {
  description = "A map of tags to assign to the Elastic IP"
  type        = map(string)
  default     = {}
}

#----------------------------------------------------------------
# Tags
#----------------------------------------------------------------
variable "tags" {
  description = "A map of tags to assign to the instance"
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "A map of tags to assign to the devices created by the instance at launch time"
  type        = map(string)
  default     = {}
}
