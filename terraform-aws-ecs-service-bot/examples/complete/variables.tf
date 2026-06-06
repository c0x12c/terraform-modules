# General Configuration
variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

# ECS Configuration
variable "ecs_cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "task_cpu" {
  description = "Task CPU units"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Task memory in MiB"
  type        = number
  default     = 2048
}

variable "container_cpu" {
  description = "Container CPU units"
  type        = number
  default     = 0
}

variable "container_memory" {
  description = "Container memory in MiB"
  type        = number
  default     = 2048
}

variable "service_desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "service_max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 2
}

# ALB & Route53 Configuration
variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "alb_security_groups" {
  description = "ALB security group IDs"
  type        = list(string)
}

variable "aws_lb_listener_arn" {
  description = "ALB listener ARN"
  type        = string
}

variable "aws_lb_listener_rule_priority" {
  description = "ALB listener rule priority"
  type        = number
  default     = 100
}

variable "alb_zone_id" {
  description = "ALB hosted zone ID"
  type        = string
}

variable "dns_name" {
  description = "DNS name (subdomain)"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "app_domain" {
  description = "Application domain (full domain)"
  type        = string
  default     = "example.com"
}

# Slack Secrets (should be passed in securely)
variable "slack_signing_secret" {
  description = "Slack signing secret"
  type        = string
  sensitive   = true
}

variable "slack_bot_token" {
  description = "Slack bot token"
  type        = string
  sensitive   = true
}

variable "slack_user_token" {
  description = "Slack user token"
  type        = string
  sensitive   = true
}

variable "slack_bot_user_id" {
  description = "Slack bot user ID"
  type        = string
}

variable "allowed_slack_channel" {
  description = "Allowed Slack channel ID"
  type        = string
}

variable "slack_channel_prefix" {
  description = "Slack channel prefix"
  type        = string
}

variable "on_call_slack_channel" {
  description = "On-call Slack channel"
  type        = string
  default     = "on-call"
}

variable "slack_user_group_names" {
  description = "Slack user group names"
  type        = string
  default     = "dev-system"
}

# GitHub Secrets (should be passed in securely)
variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
  sensitive   = true
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
  sensitive   = true
}

variable "github_app_private_key" {
  description = "GitHub App private key"
  type        = string
  sensitive   = true
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
}

variable "app_repo_list" {
  description = "List of application repositories"
  type        = list(string)
}

variable "infra_repo_list" {
  description = "List of infrastructure repositories"
  type        = list(string)
  default     = []
}

# Jenkins Configuration (optional)
variable "jenkins_username" {
  description = "Jenkins username"
  type        = string
  default     = "spartan"
}

variable "jenkins_host" {
  description = "Jenkins host URL"
  type        = string
  default     = "https://jenkins.example.com"
}

variable "jenkins_repository" {
  description = "Jenkins repository"
  type        = string
  default     = "jenkins-job-dsl-scripts"
}

variable "jenkins_api_token" {
  description = "Jenkins API token"
  type        = string
  sensitive   = true
  default     = null
}

# Atlassian Configuration (optional)
variable "atlassian_host" {
  description = "Atlassian host URL"
  type        = string
  default     = "https://example.atlassian.net"
}

variable "atlassian_username" {
  description = "Atlassian username"
  type        = string
  default     = "spartan"
}

variable "atlassian_page_path_prefix" {
  description = "Atlassian page path prefix"
  type        = string
  default     = "wiki/spaces/C0X12C/pages"
}

variable "space_id" {
  description = "Confluence Space ID"
  type        = string
  default     = "12779524"
}

variable "on_call_page_id" {
  description = "On-call page ID"
  type        = string
  default     = "48660500"
}

variable "on_call_template_page_id" {
  description = "On-call template page ID"
  type        = string
  default     = "30736481"
}

variable "on_call_process_page_id" {
  description = "On-call process page ID"
  type        = string
  default     = "41812488"
}

variable "atlassian_api_token" {
  description = "Atlassian API token"
  type        = string
  sensitive   = true
  default     = null
}

# Notification Configuration
variable "enabled_notification" {
  description = "Enable ECS event notifications"
  type        = bool
  default     = false
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  sensitive   = true
  default     = null
}
