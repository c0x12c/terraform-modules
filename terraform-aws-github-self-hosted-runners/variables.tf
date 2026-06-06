variable "source_ami" {
  description = "The AMI ID for the EC2 instance used by the source instance."
  type        = string
  default     = "ami-00c257e12d6828491"
}

variable "source_instance_type" {
  description = "The EC2 instance type to use by the source instance"
  type        = string
  default     = "t3.micro"
}

variable "instance_type" {
  description = "The EC2 instance type to use for the GitHub Runner."
  type        = string
  default     = "t3.micro"
}

variable "org_name" {
  description = "The name of the GitHub Organization to register the GitHub Runner with."
  type        = string
}

variable "github_actions_runner_registration_token" {
  description = "The token for registering the GitHub Runner with the GitHub Organization."
  type        = string
}

variable "runner_version" {
  description = "The version of the GitHub Runner software to be installed."
  default     = "2.321.0"
  type        = string
}

variable "health_check_grace_period" {
  description = "The duration (in seconds) for the Auto Scaling Group's health check grace period."
  type        = number
  default     = 600
}

variable "desired_capacity" {
  description = "The desired number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 1
}

variable "min_size" {
  description = "The minimum number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 1
}

variable "runner_home" {
  description = "The home directory for the GitHub Runner."
  type        = string
  default     = "/home/ubuntu/actions-runner"
}

variable "runner_labels" {
  description = "Labels assigned to the GitHub Runner."
  type        = string
  default     = "self-hosted,ec2"
}

variable "security_group_ids" {
  description = "The list of security group IDs."
  type        = list(string)
}

variable "subnet_ids" {
  description = "The list of subnets for the EC2 instances of the Auto Scaling Group."
  type        = list(string)
}

variable "update_default_launch_template_version" {
  description = "Whether to update the default version of the launch template."
  type        = bool
  default     = true
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

variable "custom_ami_name" {
  type        = string
  description = "The name of the custom AMI to use for the EC2 instances."
}

variable "terraform_version" {
  type        = string
  default     = "1.10.1"
  description = "The version of Terraform to be used."
}
