# Terraform AWS Helm Service Bot

This Terraform module deploys a Service Bot on AWS EKS using Helm. The Service Bot automates DevOps workflows and provides team collaboration features through integrations with Slack, GitHub, Jenkins, and Atlassian products (Jira/Confluence).

## Features

*   **Automated Deployment**: Deploys the Service Bot application using the `spartan` Helm chart with AWS ALB Ingress.
*   **Kubernetes Management**: Configures ServiceAccount with RBAC permissions, namespaces, ConfigMaps, and Secrets.
*   **Multi-Platform Integration**: Connects to Slack for notifications, GitHub App for repository management, Jenkins for CI/CD, and Atlassian for documentation.
*   **Secure Configuration**: Uses Kubernetes secrets for sensitive data and supports IAM roles for service accounts (IRSA).
*   **Customizable Resources**: Allows configuration of pod resources, replica counts, and health check endpoints.

## Usage

```hcl
module "service_bot" {
  source  = "c0x12c/helm-service-bot/aws"
  version = "0.4.0"

  cluster_name      = "my-eks-cluster"
  eks_oidc_provider = {
    arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
    url = "https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
  }
  region            = "us-east-1"
  route53_zone_id   = "Z0123456789ABCDEF"
  alb_dns           = "my-alb-dns-name.us-east-1.elb.amazonaws.com"
  environment       = "dev"

  # Slack Configuration
  slack_signing_secret  = var.slack_signing_secret
  slack_bot_token       = var.slack_bot_token
  slack_user_token      = var.slack_user_token
  slack_bot_user_id     = "U12345678"
  allowed_slack_channel = "C12345678"
  slack_channel_prefix  = "prj-spartan-"

  # GitHub Configuration (GitHub App)
  github_org                  = "my-org"
  app_repo_list               = ["repo-1", "repo-2"]
  github_app_id               = "123456"
  github_app_installation_id  = "87654321"
  github_app_private_key      = var.github_app_private_key

  # Jenkins Configuration (optional)
  jenkins_username  = "jenkins-user"
  jenkins_api_token = var.jenkins_api_token

  # Atlassian Configuration (optional)
  atlassian_username  = "atlassian-user"
  atlassian_api_token = var.atlassian_api_token
}
```

## Examples

Refer to the [complete example](examples/complete) for a full implementation including provider configuration.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_service"></a> [eks\_service](#module\_eks\_service) | c0x12c/eks-service/aws | 0.2.8 |

## Resources

| Name | Type |
|------|------|
| [helm_release.service_bot](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role_binding_v1.service_bot](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_cluster_role_v1.service_bot](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_dns"></a> [alb\_dns](#input\_alb\_dns) | The DNS name of the ALB | `string` | n/a | yes |
| <a name="input_allowed_slack_channel"></a> [allowed\_slack\_channel](#input\_allowed\_slack\_channel) | Allowed Slack channel | `string` | n/a | yes |
| <a name="input_app_domain"></a> [app\_domain](#input\_app\_domain) | The application domain | `string` | `"example.com"` | no |
| <a name="input_app_repo_list"></a> [app\_repo\_list](#input\_app\_repo\_list) | List of application repositories | `list(string)` | n/a | yes |
| <a name="input_atlassian_api_token"></a> [atlassian\_api\_token](#input\_atlassian\_api\_token) | Atlassian API token | `string` | `null` | no |
| <a name="input_atlassian_host"></a> [atlassian\_host](#input\_atlassian\_host) | Atlassian host URL | `string` | `"https://example.atlassian.net"` | no |
| <a name="input_atlassian_page_path_prefix"></a> [atlassian\_page\_path\_prefix](#input\_atlassian\_page\_path\_prefix) | Atlassian page path prefix | `string` | `"wiki/spaces/C0X12C/pages"` | no |
| <a name="input_atlassian_username"></a> [atlassian\_username](#input\_atlassian\_username) | Atlassian username | `string` | `"spartan"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | n/a | yes |
| <a name="input_eks_oidc_provider"></a> [eks\_oidc\_provider](#input\_eks\_oidc\_provider) | The OIDC provider for the EKS cluster | `object({ arn = string, url = string })` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The micronaut environment | `string` | n/a | yes |
| <a name="input_github_app_id"></a> [github\_app\_id](#input\_github\_app\_id) | GitHub App ID | `string` | n/a | yes |
| <a name="input_github_app_installation_id"></a> [github\_app\_installation\_id](#input\_github\_app\_installation\_id) | GitHub App Installation ID | `string` | n/a | yes |
| <a name="input_github_app_private_key"></a> [github\_app\_private\_key](#input\_github\_app\_private\_key) | GitHub App private key | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub organization name | `string` | n/a | yes |
| <a name="input_http_client_log_level"></a> [http\_client\_log\_level](#input\_http\_client\_log\_level) | HTTP client log level | `string` | `"INFO"` | no |
| <a name="input_infra_repo_list"></a> [infra\_repo\_list](#input\_infra\_repo\_list) | List of infrastructure repositories | `list(string)` | `[]` | no |
| <a name="input_jenkins_api_token"></a> [jenkins\_api\_token](#input\_jenkins\_api\_token) | Jenkins API token | `string` | `null` | no |
| <a name="input_jenkins_host"></a> [jenkins\_host](#input\_jenkins\_host) | Jenkins host URL | `string` | `"https://jenkins.example.com"` | no |
| <a name="input_jenkins_repository"></a> [jenkins\_repository](#input\_jenkins\_repository) | Jenkins repository | `string` | `"jenkins-job-dsl-scripts"` | no |
| <a name="input_jenkins_username"></a> [jenkins\_username](#input\_jenkins\_username) | Jenkins username | `string` | `"spartan"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace to deploy the service | `string` | `"service-bot"` | no |
| <a name="input_on_call_page_id"></a> [on\_call\_page\_id](#input\_on\_call\_page\_id) | On-call page ID | `string` | `"48660500"` | no |
| <a name="input_on_call_process_page_id"></a> [on\_call\_process\_page\_id](#input\_on\_call\_process\_page\_id) | On-call process page ID | `string` | `"41812488"` | no |
| <a name="input_on_call_slack_channel"></a> [on\_call\_slack\_channel](#input\_on\_call\_slack\_channel) | On-call Slack channel | `string` | `"on-call"` | no |
| <a name="input_on_call_template_page_id"></a> [on\_call\_template\_page\_id](#input\_on\_call\_template\_page\_id) | On-call template page ID | `string` | `"30736481"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route53 hosted zone ID | `string` | n/a | yes |
| <a name="input_service_bot_image_repository"></a> [service\_bot\_image\_repository](#input\_service\_bot\_image\_repository) | Docker image for the service bot | `string` | `"ghcr.io/spartan-stratos/service-bot"` | no |
| <a name="input_service_bot_image_tag"></a> [service\_bot\_image\_tag](#input\_service\_bot\_image\_tag) | Docker image tag for the service bot | `string` | `"v0.2.0"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The name of the service | `string` | `"service-bot"` | no |
| <a name="input_service_resources"></a> [service\_resources](#input\_service\_resources) | Kubernetes resource requests and limits for the service bot | `map(map(string))` | <pre>{<br/>  "limits": {<br/>    "memory": "1Gi"<br/>  },<br/>  "requests": {<br/>    "cpu": "200m",<br/>    "memory": "1Gi"<br/>  }<br/>}</pre> | no |
| <a name="input_slack_bot_token"></a> [slack\_bot\_token](#input\_slack\_bot\_token) | Slack bot token | `string` | n/a | yes |
| <a name="input_slack_bot_user_id"></a> [slack\_bot\_user\_id](#input\_slack\_bot\_user\_id) | Slack bot user ID | `string` | n/a | yes |
| <a name="input_slack_channel_prefix"></a> [slack\_channel\_prefix](#input\_slack\_channel\_prefix) | Slack channel prefix | `string` | n/a | yes |
| <a name="input_slack_signing_secret"></a> [slack\_signing\_secret](#input\_slack\_signing\_secret) | Slack signing secret | `string` | n/a | yes |
| <a name="input_slack_user_group_names"></a> [slack\_user\_group\_names](#input\_slack\_user\_group\_names) | Slack user group names | `string` | `"dev-system"` | no |
| <a name="input_slack_user_token"></a> [slack\_user\_token](#input\_slack\_user\_token) | Slack user token | `string` | n/a | yes |
| <a name="input_space_id"></a> [space\_id](#input\_space\_id) | Confluence Space ID | `string` | `"12779524"` | no |
| <a name="input_spartan_chart_version"></a> [spartan\_chart\_version](#input\_spartan\_chart\_version) | Version of the Spartan Helm chart to deploy | `string` | `"0.1.18"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
