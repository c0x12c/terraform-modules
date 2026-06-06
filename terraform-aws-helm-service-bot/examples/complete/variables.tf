variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "eks_oidc_provider" {
  description = "The OIDC provider for the EKS cluster"
  type        = object({ arn = string, url = string })
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "alb_dns" {
  description = "The DNS name of the ALB"
  type        = string
}

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
  description = "Allowed Slack channel"
  type        = string
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "app_repo_list" {
  description = "List of application repositories"
  type        = list(string)
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
}

variable "github_app_private_key" {
  description = "GitHub App private key"
  type        = string
  sensitive   = true
}

variable "jenkins_username" {
  description = "Jenkins username"
  type        = string
}

variable "jenkins_api_token" {
  description = "Jenkins API token"
  type        = string
  sensitive   = true
}

variable "atlassian_username" {
  description = "Atlassian username"
  type        = string
}

variable "atlassian_api_token" {
  description = "Atlassian API token"
  type        = string
  sensitive   = true
}
