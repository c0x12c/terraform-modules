# General Configuration
variable "service_name" {
  description = "The name of the service"
  type        = string
  default     = "service-bot"
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "The AWS region in which resources are created"
  type        = string
}

variable "http_client_log_level" {
  description = "HTTP client log level"
  type        = string
  default     = "INFO"
}

# ECS Configuration
variable "ecs_cluster_id" {
  description = "ID of the ECS cluster for this service bot"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster for this service bot"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnets to associate with the ECS service"
  type        = list(string)
}

variable "task_cpu" {
  description = "Task CPU (e.g., 256, 512, 1024)"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Task memory in MiB"
  type        = number
  default     = 2048
}

variable "container_cpu" {
  description = "The number of cpu units reserved for the container"
  type        = number
  default     = 0
}

variable "container_memory" {
  description = "The amount (in MiB) of memory reserved for the container"
  type        = number
  default     = 2048
}

variable "container_port" {
  description = "Port exposed by the service bot container"
  type        = number
  default     = 8080
}

variable "service_desired_count" {
  description = "Number of tasks running in parallel"
  type        = number
  default     = 1
}

variable "service_max_capacity" {
  description = "Maximum number of tasks running in parallel"
  type        = number
  default     = 2
}

variable "enable_autoscaling" {
  description = "Whether to enable autoscaling for the ECS service"
  type        = bool
  default     = true
}

variable "enable_execute_command" {
  description = "Whether to enable execute command for the ECS task"
  type        = bool
  default     = false
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks"
  type        = bool
  default     = false
}

variable "launch_type" {
  description = "Launch type on which to run your service (EC2, FARGATE, or EXTERNAL)"
  type        = string
  default     = "FARGATE"
}

variable "health_check_enabled" {
  description = "Enable health check for the ECS service"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "force_new_deployment" {
  description = "Force a new task deployment"
  type        = bool
  default     = true
}

# Service Bot Configuration
variable "service_bot_image" {
  description = "Docker image for the service bot (include tag)"
  type        = string
  default     = "ghcr.io/spartan-stratos/service-bot:v0.3.1"
}

# ALB & Route53 Configuration
variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_security_groups" {
  description = "List of security group IDs of the ALB"
  type        = list(string)
}

variable "aws_lb_listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "aws_lb_listener_rule_priority" {
  description = "Priority for the ALB listener rule"
  type        = number
  default     = 100
}

variable "alb_zone_id" {
  description = "Hosted zone ID of the ALB"
  type        = string
}

variable "dns_name" {
  description = "DNS name for the service bot (subdomain)"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "app_domain" {
  description = "The application domain (full domain name)"
  type        = string
  default     = "example.com"
}

# Slack Configuration (Required)
variable "slack_signing_secret_arn" {
  description = "SSM Parameter Store or Secrets Manager ARN for Slack signing secret"
  type        = string
}

variable "slack_bot_token_arn" {
  description = "SSM Parameter Store or Secrets Manager ARN for Slack bot token"
  type        = string
}

variable "slack_user_token_arn" {
  description = "SSM Parameter Store or Secrets Manager ARN for Slack user token"
  type        = string
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
  description = "On-call Slack channel name"
  type        = string
  default     = "on-call"
}

variable "slack_user_group_names" {
  description = "Slack user group names"
  type        = string
  default     = "dev-system"
}

# GitHub Configuration (Required)
variable "github_org" {
  description = "GitHub organization name"
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

variable "github_app_id_arn" {
  description = "SSM Parameter Store or Secrets Manager ARN for GitHub App ID"
  type        = string
}

variable "github_app_installation_id_arn" {
  description = "SSM Parameter Store or Secrets Manager ARN for GitHub App Installation ID"
  type        = string
}

variable "github_app_private_key_arn" {
  description = "SSM Parameter Store or Secrets Manager ARN for GitHub App private key"
  type        = string
}

# Jenkins Configuration (Optional)
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

variable "jenkins_api_token_arn" {
  description = "SSM Parameter Store or Secrets Manager ARN for Jenkins API token"
  type        = string
  default     = null
}

# Atlassian Configuration (Optional)
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

variable "atlassian_api_token_arn" {
  description = "SSM Parameter Store or Secrets Manager ARN for Atlassian API token"
  type        = string
  default     = null
}

# IAM Configuration
variable "ecs_execution_policy_arns" {
  description = "IAM policy ARNs for ECS task execution role"
  type        = list(string)
  default     = []
}

variable "additional_iam_policy_arns" {
  description = "Additional IAM policy ARNs for ECS task role"
  type        = list(string)
  default     = []
}

# Additional Configuration
variable "additional_environment_variables" {
  description = "Additional environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "additional_secret_arns" {
  description = "Additional secret ARNs for the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# Notification Configuration
variable "enabled_notification" {
  description = "Whether to enable ECS service and task event notifications"
  type        = bool
  default     = false
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for sending notifications"
  type        = string
  sensitive   = true
  default     = null
}

variable "notification_deployment_event_types" {
  description = "List of ECS deployment event types for notifications"
  type        = list(string)
  default = [
    "SERVICE_DEPLOYMENT_IN_PROGRESS",
    "SERVICE_DEPLOYMENT_COMPLETED",
    "SERVICE_DEPLOYMENT_FAILED"
  ]
}

variable "notification_service_event_types" {
  description = "List of ECS service event types for notifications"
  type        = list(string)
  default     = ["SERVICE_TASK_PLACEMENT_FAILURE", "SERVICE_STEADY_STATE"]
}

variable "notification_task_stop_codes" {
  description = "List of ECS task stop codes for notifications"
  type        = list(string)
  default     = ["TaskFailedToStart", "EssentialContainerExited", "ContainerFailedToStart"]
}

# Datadog Configuration
variable "enabled_datadog_sidecar" {
  description = "Enable Datadog sidecar for monitoring and logging"
  type        = bool
  default     = false
}

variable "dd_site" {
  description = "Datadog site (e.g., datadoghq.com, us3.datadoghq.com)"
  type        = string
  default     = null
}

variable "dd_api_key_arn" {
  description = "SSM Parameter Store or Secrets Manager ARN for Datadog API key"
  type        = string
  default     = null
}

variable "dd_agent_image" {
  description = "Datadog agent Docker image"
  type        = string
  default     = "public.ecr.aws/datadog/agent:latest"
}

variable "dd_port" {
  description = "Datadog agent port"
  type        = number
  default     = 8126
}

variable "dd_sidecar_environment" {
  description = "Additional environment variables for Datadog sidecar"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
