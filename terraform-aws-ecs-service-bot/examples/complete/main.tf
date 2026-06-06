terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Example: Create SSM Parameters for secrets
# In production, you would likely manage these separately
resource "aws_ssm_parameter" "slack_signing_secret" {
  name  = "/service-bot/SLACK_SIGNING_SECRET"
  type  = "SecureString"
  value = var.slack_signing_secret
}

resource "aws_ssm_parameter" "slack_bot_token" {
  name  = "/service-bot/SLACK_BOT_TOKEN"
  type  = "SecureString"
  value = var.slack_bot_token
}

resource "aws_ssm_parameter" "slack_user_token" {
  name  = "/service-bot/SLACK_USER_TOKEN"
  type  = "SecureString"
  value = var.slack_user_token
}

resource "aws_ssm_parameter" "github_app_id" {
  name  = "/service-bot/GITHUB_APP_ID"
  type  = "SecureString"
  value = var.github_app_id
}

resource "aws_ssm_parameter" "github_app_installation_id" {
  name  = "/service-bot/GITHUB_APP_INSTALLATION_ID"
  type  = "SecureString"
  value = var.github_app_installation_id
}

resource "aws_ssm_parameter" "github_app_private_key" {
  name  = "/service-bot/GITHUB_APP_PRIVATE_KEY"
  type  = "SecureString"
  value = var.github_app_private_key
}

# Optional Jenkins and Atlassian secrets
resource "aws_ssm_parameter" "jenkins_api_token" {
  count = var.jenkins_api_token != null ? 1 : 0

  name  = "/service-bot/JENKINS_API_TOKEN"
  type  = "SecureString"
  value = var.jenkins_api_token
}

resource "aws_ssm_parameter" "atlassian_api_token" {
  count = var.atlassian_api_token != null ? 1 : 0

  name  = "/service-bot/ATLASSIAN_API_TOKEN"
  type  = "SecureString"
  value = var.atlassian_api_token
}

# Service Bot Module
module "service_bot" {
  source = "../../"

  service_name = "service-bot"
  environment  = var.environment
  region       = var.region

  # ECS Configuration
  ecs_cluster_id   = var.ecs_cluster_id
  ecs_cluster_name = var.ecs_cluster_name
  vpc_id           = var.vpc_id
  subnet_ids       = var.subnet_ids

  # Task Configuration (optional overrides)
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  container_cpu         = var.container_cpu
  container_memory      = var.container_memory
  service_desired_count = var.service_desired_count
  service_max_capacity  = var.service_max_capacity

  # ALB & Route53
  alb_dns_name                  = var.alb_dns_name
  alb_security_groups           = var.alb_security_groups
  aws_lb_listener_arn           = var.aws_lb_listener_arn
  aws_lb_listener_rule_priority = var.aws_lb_listener_rule_priority
  alb_zone_id                   = var.alb_zone_id
  dns_name                      = var.dns_name
  route53_zone_id               = var.route53_zone_id
  app_domain                    = var.app_domain

  # Slack Configuration (using SSM Parameter ARNs)
  slack_signing_secret_arn = aws_ssm_parameter.slack_signing_secret.arn
  slack_bot_token_arn      = aws_ssm_parameter.slack_bot_token.arn
  slack_user_token_arn     = aws_ssm_parameter.slack_user_token.arn
  slack_bot_user_id        = var.slack_bot_user_id
  allowed_slack_channel    = var.allowed_slack_channel
  slack_channel_prefix     = var.slack_channel_prefix
  on_call_slack_channel    = var.on_call_slack_channel
  slack_user_group_names   = var.slack_user_group_names

  # GitHub Configuration (using SSM Parameter ARNs)
  github_org                     = var.github_org
  app_repo_list                  = var.app_repo_list
  infra_repo_list                = var.infra_repo_list
  github_app_id_arn              = aws_ssm_parameter.github_app_id.arn
  github_app_installation_id_arn = aws_ssm_parameter.github_app_installation_id.arn
  github_app_private_key_arn     = aws_ssm_parameter.github_app_private_key.arn

  # Jenkins Configuration (optional)
  jenkins_username      = var.jenkins_username
  jenkins_host          = var.jenkins_host
  jenkins_repository    = var.jenkins_repository
  jenkins_api_token_arn = try(aws_ssm_parameter.jenkins_api_token[0].arn, null)

  # Atlassian Configuration (optional)
  atlassian_host             = var.atlassian_host
  atlassian_username         = var.atlassian_username
  atlassian_page_path_prefix = var.atlassian_page_path_prefix
  space_id                   = var.space_id
  on_call_page_id            = var.on_call_page_id
  on_call_template_page_id   = var.on_call_template_page_id
  on_call_process_page_id    = var.on_call_process_page_id
  atlassian_api_token_arn    = try(aws_ssm_parameter.atlassian_api_token[0].arn, null)

  # Enable notifications (optional)
  enabled_notification = var.enabled_notification
  slack_webhook_url    = var.slack_webhook_url
}
