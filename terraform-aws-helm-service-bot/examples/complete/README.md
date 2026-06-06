# Basic Example

This example demonstrates how to use the `terraform-aws-helm-service-bot` module to deploy the service bot.

## Usage

To run this example, you need to provide the required variables. You can do this by creating a `terraform.tfvars` file or by passing them via command line arguments.

```bash
terraform init
terraform apply
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_service_bot"></a> [service\_bot](#module\_service\_bot) | ../../ | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_dns"></a> [alb\_dns](#input\_alb\_dns) | The DNS name of the ALB | `string` | n/a | yes |
| <a name="input_allowed_slack_channel"></a> [allowed\_slack\_channel](#input\_allowed\_slack\_channel) | Allowed Slack channel | `string` | n/a | yes |
| <a name="input_app_repo_list"></a> [app\_repo\_list](#input\_app\_repo\_list) | List of application repositories | `list(string)` | n/a | yes |
| <a name="input_atlassian_api_token"></a> [atlassian\_api\_token](#input\_atlassian\_api\_token) | Atlassian API token | `string` | n/a | yes |
| <a name="input_atlassian_username"></a> [atlassian\_username](#input\_atlassian\_username) | Atlassian username | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | n/a | yes |
| <a name="input_eks_oidc_provider"></a> [eks\_oidc\_provider](#input\_eks\_oidc\_provider) | The OIDC provider for the EKS cluster | `object({ arn = string, url = string })` | n/a | yes |
| <a name="input_github_app_id"></a> [github\_app\_id](#input\_github\_app\_id) | GitHub App ID | `string` | n/a | yes |
| <a name="input_github_app_installation_id"></a> [github\_app\_installation\_id](#input\_github\_app\_installation\_id) | GitHub App Installation ID | `string` | n/a | yes |
| <a name="input_github_app_private_key"></a> [github\_app\_private\_key](#input\_github\_app\_private\_key) | GitHub App private key | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub organization name | `string` | n/a | yes |
| <a name="input_jenkins_api_token"></a> [jenkins\_api\_token](#input\_jenkins\_api\_token) | Jenkins API token | `string` | n/a | yes |
| <a name="input_jenkins_username"></a> [jenkins\_username](#input\_jenkins\_username) | Jenkins username | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route53 hosted zone ID | `string` | n/a | yes |
| <a name="input_slack_bot_token"></a> [slack\_bot\_token](#input\_slack\_bot\_token) | Slack bot token | `string` | n/a | yes |
| <a name="input_slack_bot_user_id"></a> [slack\_bot\_user\_id](#input\_slack\_bot\_user\_id) | Slack bot user ID | `string` | n/a | yes |
| <a name="input_slack_signing_secret"></a> [slack\_signing\_secret](#input\_slack\_signing\_secret) | Slack signing secret | `string` | n/a | yes |
| <a name="input_slack_user_token"></a> [slack\_user\_token](#input\_slack\_user\_token) | Slack user token | `string` | n/a | yes |
