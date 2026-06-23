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
  source  = "terraform.c0x12c.com/c0x12c/ecs-service-bot/aws"
  version = "0.1.0"

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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_main"></a> [main](#module\_main) | ../terraform-aws-ecs-application | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_environment_variables"></a> [additional\_environment\_variables](#input\_additional\_environment\_variables) | Additional environment variables for the container | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_additional_iam_policy_arns"></a> [additional\_iam\_policy\_arns](#input\_additional\_iam\_policy\_arns) | Additional IAM policy ARNs for ECS task role | `list(string)` | `[]` | no |
| <a name="input_additional_secret_arns"></a> [additional\_secret\_arns](#input\_additional\_secret\_arns) | Additional secret ARNs for the container | <pre>list(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `[]` | no |
| <a name="input_alb_dns_name"></a> [alb\_dns\_name](#input\_alb\_dns\_name) | DNS name of the Application Load Balancer | `string` | n/a | yes |
| <a name="input_alb_security_groups"></a> [alb\_security\_groups](#input\_alb\_security\_groups) | List of security group IDs of the ALB | `list(string)` | n/a | yes |
| <a name="input_alb_zone_id"></a> [alb\_zone\_id](#input\_alb\_zone\_id) | Hosted zone ID of the ALB | `string` | n/a | yes |
| <a name="input_allowed_slack_channel"></a> [allowed\_slack\_channel](#input\_allowed\_slack\_channel) | Allowed Slack channel ID | `string` | n/a | yes |
| <a name="input_app_domain"></a> [app\_domain](#input\_app\_domain) | The application domain (full domain name) | `string` | `"example.com"` | no |
| <a name="input_app_repo_list"></a> [app\_repo\_list](#input\_app\_repo\_list) | List of application repositories | `list(string)` | n/a | yes |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign public IP to tasks | `bool` | `false` | no |
| <a name="input_atlassian_api_token_arn"></a> [atlassian\_api\_token\_arn](#input\_atlassian\_api\_token\_arn) | SSM Parameter Store or Secrets Manager ARN for Atlassian API token | `string` | `null` | no |
| <a name="input_atlassian_host"></a> [atlassian\_host](#input\_atlassian\_host) | Atlassian host URL | `string` | `"https://example.atlassian.net"` | no |
| <a name="input_atlassian_page_path_prefix"></a> [atlassian\_page\_path\_prefix](#input\_atlassian\_page\_path\_prefix) | Atlassian page path prefix | `string` | `"wiki/spaces/C0X12C/pages"` | no |
| <a name="input_atlassian_username"></a> [atlassian\_username](#input\_atlassian\_username) | Atlassian username | `string` | `"spartan"` | no |
| <a name="input_aws_lb_listener_arn"></a> [aws\_lb\_listener\_arn](#input\_aws\_lb\_listener\_arn) | ARN of the ALB listener | `string` | n/a | yes |
| <a name="input_aws_lb_listener_rule_priority"></a> [aws\_lb\_listener\_rule\_priority](#input\_aws\_lb\_listener\_rule\_priority) | Priority for the ALB listener rule | `number` | `100` | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | The number of cpu units reserved for the container | `number` | `0` | no |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | The amount (in MiB) of memory reserved for the container | `number` | `2048` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port exposed by the service bot container | `number` | `8080` | no |
| <a name="input_dd_agent_image"></a> [dd\_agent\_image](#input\_dd\_agent\_image) | Datadog agent Docker image | `string` | `"public.ecr.aws/datadog/agent:latest"` | no |
| <a name="input_dd_api_key_arn"></a> [dd\_api\_key\_arn](#input\_dd\_api\_key\_arn) | SSM Parameter Store or Secrets Manager ARN for Datadog API key | `string` | `null` | no |
| <a name="input_dd_port"></a> [dd\_port](#input\_dd\_port) | Datadog agent port | `number` | `8126` | no |
| <a name="input_dd_sidecar_environment"></a> [dd\_sidecar\_environment](#input\_dd\_sidecar\_environment) | Additional environment variables for Datadog sidecar | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_dd_site"></a> [dd\_site](#input\_dd\_site) | Datadog site (e.g., datadoghq.com, us3.datadoghq.com) | `string` | `null` | no |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | DNS name for the service bot (subdomain) | `string` | n/a | yes |
| <a name="input_ecs_cluster_id"></a> [ecs\_cluster\_id](#input\_ecs\_cluster\_id) | ID of the ECS cluster for this service bot | `string` | n/a | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of the ECS cluster for this service bot | `string` | n/a | yes |
| <a name="input_ecs_execution_policy_arns"></a> [ecs\_execution\_policy\_arns](#input\_ecs\_execution\_policy\_arns) | IAM policy ARNs for ECS task execution role | `list(string)` | `[]` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Whether to enable autoscaling for the ECS service | `bool` | `true` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Whether to enable execute command for the ECS task | `bool` | `false` | no |
| <a name="input_enabled_datadog_sidecar"></a> [enabled\_datadog\_sidecar](#input\_enabled\_datadog\_sidecar) | Enable Datadog sidecar for monitoring and logging | `bool` | `false` | no |
| <a name="input_enabled_notification"></a> [enabled\_notification](#input\_enabled\_notification) | Whether to enable ECS service and task event notifications | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Force a new task deployment | `bool` | `true` | no |
| <a name="input_github_app_id_arn"></a> [github\_app\_id\_arn](#input\_github\_app\_id\_arn) | SSM Parameter Store or Secrets Manager ARN for GitHub App ID | `string` | n/a | yes |
| <a name="input_github_app_installation_id_arn"></a> [github\_app\_installation\_id\_arn](#input\_github\_app\_installation\_id\_arn) | SSM Parameter Store or Secrets Manager ARN for GitHub App Installation ID | `string` | n/a | yes |
| <a name="input_github_app_private_key_arn"></a> [github\_app\_private\_key\_arn](#input\_github\_app\_private\_key\_arn) | SSM Parameter Store or Secrets Manager ARN for GitHub App private key | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub organization name | `string` | n/a | yes |
| <a name="input_health_check_enabled"></a> [health\_check\_enabled](#input\_health\_check\_enabled) | Enable health check for the ECS service | `bool` | `true` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Health check path | `string` | `"/health"` | no |
| <a name="input_http_client_log_level"></a> [http\_client\_log\_level](#input\_http\_client\_log\_level) | HTTP client log level | `string` | `"INFO"` | no |
| <a name="input_infra_repo_list"></a> [infra\_repo\_list](#input\_infra\_repo\_list) | List of infrastructure repositories | `list(string)` | `[]` | no |
| <a name="input_jenkins_api_token_arn"></a> [jenkins\_api\_token\_arn](#input\_jenkins\_api\_token\_arn) | SSM Parameter Store or Secrets Manager ARN for Jenkins API token | `string` | `null` | no |
| <a name="input_jenkins_host"></a> [jenkins\_host](#input\_jenkins\_host) | Jenkins host URL | `string` | `"https://jenkins.example.com"` | no |
| <a name="input_jenkins_repository"></a> [jenkins\_repository](#input\_jenkins\_repository) | Jenkins repository | `string` | `"jenkins-job-dsl-scripts"` | no |
| <a name="input_jenkins_username"></a> [jenkins\_username](#input\_jenkins\_username) | Jenkins username | `string` | `"spartan"` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | Launch type on which to run your service (EC2, FARGATE, or EXTERNAL) | `string` | `"FARGATE"` | no |
| <a name="input_notification_deployment_event_types"></a> [notification\_deployment\_event\_types](#input\_notification\_deployment\_event\_types) | List of ECS deployment event types for notifications | `list(string)` | <pre>[<br/>  "SERVICE_DEPLOYMENT_IN_PROGRESS",<br/>  "SERVICE_DEPLOYMENT_COMPLETED",<br/>  "SERVICE_DEPLOYMENT_FAILED"<br/>]</pre> | no |
| <a name="input_notification_service_event_types"></a> [notification\_service\_event\_types](#input\_notification\_service\_event\_types) | List of ECS service event types for notifications | `list(string)` | <pre>[<br/>  "SERVICE_TASK_PLACEMENT_FAILURE",<br/>  "SERVICE_STEADY_STATE"<br/>]</pre> | no |
| <a name="input_notification_task_stop_codes"></a> [notification\_task\_stop\_codes](#input\_notification\_task\_stop\_codes) | List of ECS task stop codes for notifications | `list(string)` | <pre>[<br/>  "TaskFailedToStart",<br/>  "EssentialContainerExited",<br/>  "ContainerFailedToStart"<br/>]</pre> | no |
| <a name="input_on_call_page_id"></a> [on\_call\_page\_id](#input\_on\_call\_page\_id) | On-call page ID | `string` | `"48660500"` | no |
| <a name="input_on_call_process_page_id"></a> [on\_call\_process\_page\_id](#input\_on\_call\_process\_page\_id) | On-call process page ID | `string` | `"41812488"` | no |
| <a name="input_on_call_slack_channel"></a> [on\_call\_slack\_channel](#input\_on\_call\_slack\_channel) | On-call Slack channel name | `string` | `"on-call"` | no |
| <a name="input_on_call_template_page_id"></a> [on\_call\_template\_page\_id](#input\_on\_call\_template\_page\_id) | On-call template page ID | `string` | `"30736481"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region in which resources are created | `string` | n/a | yes |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route53 hosted zone ID | `string` | n/a | yes |
| <a name="input_service_bot_image"></a> [service\_bot\_image](#input\_service\_bot\_image) | Docker image for the service bot (include tag) | `string` | `"ghcr.io/spartan-stratos/service-bot:v0.3.1"` | no |
| <a name="input_service_desired_count"></a> [service\_desired\_count](#input\_service\_desired\_count) | Number of tasks running in parallel | `number` | `1` | no |
| <a name="input_service_max_capacity"></a> [service\_max\_capacity](#input\_service\_max\_capacity) | Maximum number of tasks running in parallel | `number` | `2` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The name of the service | `string` | `"service-bot"` | no |
| <a name="input_slack_bot_token_arn"></a> [slack\_bot\_token\_arn](#input\_slack\_bot\_token\_arn) | SSM Parameter Store or Secrets Manager ARN for Slack bot token | `string` | n/a | yes |
| <a name="input_slack_bot_user_id"></a> [slack\_bot\_user\_id](#input\_slack\_bot\_user\_id) | Slack bot user ID | `string` | n/a | yes |
| <a name="input_slack_channel_prefix"></a> [slack\_channel\_prefix](#input\_slack\_channel\_prefix) | Slack channel prefix | `string` | n/a | yes |
| <a name="input_slack_signing_secret_arn"></a> [slack\_signing\_secret\_arn](#input\_slack\_signing\_secret\_arn) | SSM Parameter Store or Secrets Manager ARN for Slack signing secret | `string` | n/a | yes |
| <a name="input_slack_user_group_names"></a> [slack\_user\_group\_names](#input\_slack\_user\_group\_names) | Slack user group names | `string` | `"dev-system"` | no |
| <a name="input_slack_user_token_arn"></a> [slack\_user\_token\_arn](#input\_slack\_user\_token\_arn) | SSM Parameter Store or Secrets Manager ARN for Slack user token | `string` | n/a | yes |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | Slack webhook URL for sending notifications | `string` | `null` | no |
| <a name="input_space_id"></a> [space\_id](#input\_space\_id) | Confluence Space ID | `string` | `"12779524"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnets to associate with the ECS service | `list(string)` | n/a | yes |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | Task CPU (e.g., 256, 512, 1024) | `number` | `512` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Task memory in MiB | `number` | `2048` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_domain_name"></a> [application\_domain\_name](#output\_application\_domain\_name) | The domain name of the service bot application |
<!-- END_TF_DOCS -->
