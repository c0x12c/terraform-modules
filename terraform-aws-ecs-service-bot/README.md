# Terraform AWS ECS Service Bot

This Terraform module deploys a Service Bot on AWS ECS using Fargate. The Service Bot automates DevOps workflows and provides team collaboration features through integrations with Slack, GitHub, Jenkins, and Atlassian products (Jira/Confluence).

## Features

*   **Automated Deployment**: Deploys the Service Bot application as an ECS service using the `terraform-aws-ecs-application` module
*   **ECS Fargate Support**: Runs on AWS Fargate for serverless container execution
*   **Multi-Platform Integration**: Connects to Slack for notifications, GitHub App for repository management, Jenkins for CI/CD, and Atlassian for documentation
*   **Secure Configuration**: Uses AWS SSM Parameter Store or Secrets Manager for sensitive data with IAM roles for task execution
*   **Customizable Resources**: Allows configuration of task CPU/memory, desired count, and health check settings
*   **ALB Integration**: Configures Application Load Balancer listener rules and Route53 DNS records
*   **Event Notifications**: Optional EventBridge to Slack integration for ECS deployment and task events

## Usage

```hcl
module "service_bot" {
  source  = "c0x12c/ecs-service-bot/aws"
  version = "1.0.0"

  name        = "service-bot"
  environment = "dev"
  region      = "us-east-1"

  # ECS Configuration
  ecs_cluster_id   = "my-ecs-cluster-id"
  ecs_cluster_name = "my-ecs-cluster"
  vpc_id           = "vpc-12345678"
  subnet_ids       = ["subnet-12345", "subnet-67890"]

  # ALB & Route53
  alb_dns_name              = "my-alb-dns-name.us-east-1.elb.amazonaws.com"
  alb_security_groups       = ["sg-0ea3ae12345678"]
  aws_lb_listener_arn       = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/my-alb/50dc6c495c0c9188/abc123"
  alb_zone_id               = "Z35SXDOTRQ7X7K"
  dns_name                  = "service-bot"
  route53_zone_id           = "Z0123456789ABCDEF"
  app_domain                = "service-bot.example.com"

  # Slack Configuration (using SSM Parameter Store or Secrets Manager ARNs)
  slack_signing_secret_arn = "arn:aws:ssm:us-east-1:123456789012:parameter/service-bot/SLACK_SIGNING_SECRET"
  slack_bot_token_arn      = "arn:aws:ssm:us-east-1:123456789012:parameter/service-bot/SLACK_BOT_TOKEN"
  slack_user_token_arn     = "arn:aws:ssm:us-east-1:123456789012:parameter/service-bot/SLACK_USER_TOKEN"
  slack_bot_user_id        = "U12345678"
  allowed_slack_channel    = "C12345678"
  slack_channel_prefix     = "prj-spartan-"

  # GitHub Configuration (using SSM Parameter Store or Secrets Manager ARNs)
  github_org                 = "my-org"
  app_repo_list              = ["repo-1", "repo-2"]
  github_app_id_arn          = "arn:aws:ssm:us-east-1:123456789012:parameter/service-bot/GITHUB_APP_ID"
  github_app_installation_id_arn = "arn:aws:ssm:us-east-1:123456789012:parameter/service-bot/GITHUB_APP_INSTALLATION_ID"
  github_app_private_key_arn = "arn:aws:ssm:us-east-1:123456789012:parameter/service-bot/GITHUB_APP_PRIVATE_KEY"

  # Jenkins Configuration (optional)
  jenkins_username     = "jenkins-user"
  jenkins_api_token_arn = "arn:aws:ssm:us-east-1:123456789012:parameter/service-bot/JENKINS_API_TOKEN"

  # Atlassian Configuration (optional)
  atlassian_username     = "atlassian-user"
  atlassian_api_token_arn = "arn:aws:ssm:us-east-1:123456789012:parameter/service-bot/ATLASSIAN_API_TOKEN"

  # Enable notifications
  enabled_notification = true
  slack_webhook_url    = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
}
```

## Secret Management

This module expects secrets to be stored in **AWS SSM Parameter Store** or **AWS Secrets Manager**. You must provide the ARN of each secret.

### Example: Creating SSM Parameters

```hcl
resource "aws_ssm_parameter" "slack_signing_secret" {
  name  = "/service-bot/SLACK_SIGNING_SECRET"
  type  = "SecureString"
  value = var.slack_signing_secret
}

# Repeat for other secrets...
```

Then pass the ARNs to the module:

```hcl
slack_signing_secret_arn = aws_ssm_parameter.slack_signing_secret.arn
```

## Examples

Refer to the [complete example](examples/complete) for a full implementation including provider configuration and secret management.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|--------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_service_bot"></a> [ecs\_service\_bot](#module\_ecs\_service\_bot) | c0x12c/ecs-application/aws | 1.2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_domain"></a> [app\_domain](#input\_app\_domain) | The application domain (full domain name) | `string` | `"example.com"` | no |
| <a name="input_additional_environment_variables"></a> [additional\_environment\_variables](#input\_additional\_environment\_variables) | Additional environment variables for the container | `list(object({ name = string, value = string }))` | `[]` | no |
| <a name="input_additional_secret_arns"></a> [additional\_secret\_arns](#input\_additional\_secret\_arns) | Additional secret ARNs for the container | `list(object({ name = string, valueFrom = string }))` | `[]` | no |
### ... (rest of the documentation will be auto-generated by terraform-docs)
<!-- END_TF_DOCS -->
