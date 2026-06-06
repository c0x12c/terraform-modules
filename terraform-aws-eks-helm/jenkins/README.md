# EKS-Helm/Jenkins

This module helps install and configure Jenkins via Helm chart.

## Usage

### Install Jenkins

```hcl
module "eks_helm_jenkins" {
  source = "github.com/spartan-stratos/terraform-modules//aws/eks-helm/jenkins?ref=v0.1.59"

  environment             = "dev"
  github_org_display_name = "Spartan"
  shared_lib_name         = "spartan"

  domain                         = "example.com"
  github_org                     = "spartan"
  github_app_oauth_client_id     = "spartan"
  github_app_oauth_client_secret = "super-secure"
  jenkins_shared_lib_repo        = "github.com/example/example-jenkins-shared-lib.git"
  general_secrets = {
    "secret" = "value"
  }
  jenkins_base_agent_image_repo = "jenkins/jenkins-agent"
  jenkins_base_agent_image_name = "jenkins-agent"
  jenkins_base_agent_image_tag  = "latest"
  efs_id                        = "fs-12345678"
  jenkins_env_var               = "jenkins-env-var"
  enabled_slack_notification    = false
  enabled_github_app_login      = true
  jenkins_admins = ["spartan-P00006-admin"]
  jenkins_executors = ["spartan-P00006-leader", "spartan-P00006-member"]

  enabled_init_scripts = true
  enabled_datadog      = false

  google_user_list = {
    admin = ["spartan-admin"]
    executor = ["spartan-leader"]
    viewer = ["spartan-member"]
  }
}

```

## Examples

- [Example](./examples/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.16.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.33 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=2.16.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.33 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_efs_access_point.jenkins_home](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [helm_release.jenkins](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_persistent_volume.jenkins_home](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume) | resource |
| [kubernetes_persistent_volume_claim.jenkins_home](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_plugins"></a> [additional\_plugins](#input\_additional\_plugins) | List of additional Jenkins plugins to install | `list(string)` | <pre>[<br/>  "ansicolor:1.0.6",<br/>  "blueocean:1.27.16",<br/>  "config-file-provider:982.vb_a_e458a_37021",<br/>  "credentials:1413.va_51c53703df1",<br/>  "dark-theme:524.vd675b_22b_30cb_",<br/>  "extended-read-permission:61.vf24570ff3b_e9",<br/>  "github:1.41.0",<br/>  "github-oauth:621.v33b_4394dda_4d",<br/>  "google-login:109.v022b_cf87b_e5b_",<br/>  "http_request:1.20",<br/>  "job-dsl:1.90",<br/>  "matrix-auth:3.2.4",<br/>  "nodejs:1.6.3",<br/>  "oidc-provider:89.v3dfb_6d89b_618",<br/>  "pipeline-stage-view:2.35",<br/>  "pipeline-utility-steps:2.18.0",<br/>  "role-strategy:756.v978cb_392eb_d3",<br/>  "slack:761.v2a_8770f0d169",<br/>  "sonar:2.18",<br/>  "sshd:3.350.v1080103a_10fd",<br/>  "theme-manager:278.v2e3c063e42cc",<br/>  "timestamper:1.28",<br/>  "ws-cleanup:0.48"<br/>]</pre> | no |
| <a name="input_admin_alias"></a> [admin\_alias](#input\_admin\_alias) | The alias of Jenkins admin | `string` | `"Spartan"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The Jenkins chart version | `string` | `"5.8.10"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The root domain of project | `string` | n/a | yes |
| <a name="input_efs_id"></a> [efs\_id](#input\_efs\_id) | EFS is for mounting Jenkins home | `string` | n/a | yes |
| <a name="input_efs_jenkins_access_point"></a> [efs\_jenkins\_access\_point](#input\_efs\_jenkins\_access\_point) | EFS is for mounting Jenkins home | `string` | `"/jenkins-home"` | no |
| <a name="input_efs_storage_class_name"></a> [efs\_storage\_class\_name](#input\_efs\_storage\_class\_name) | EFS storage class of Jenkins volume | `string` | `"efs"` | no |
| <a name="input_efs_volume_size"></a> [efs\_volume\_size](#input\_efs\_volume\_size) | EFS volume size | `string` | `"30Gi"` | no |
| <a name="input_enable_fargate_scheduling"></a> [enable\_fargate\_scheduling](#input\_enable\_fargate\_scheduling) | If true, Jenkins pods will be forced onto Fargate (via nodeSelector + tolerations) | `bool` | `false` | no |
| <a name="input_enabled_dark_them"></a> [enabled\_dark\_them](#input\_enabled\_dark\_them) | Enable dark theme | `bool` | `false` | no |
| <a name="input_enabled_datadog"></a> [enabled\_datadog](#input\_enabled\_datadog) | Enable Datadog monitoring | `bool` | `true` | no |
| <a name="input_enabled_github_app_login"></a> [enabled\_github\_app\_login](#input\_enabled\_github\_app\_login) | Enable Github App login, only one of Github App login or Google login can be enabled | `bool` | `false` | no |
| <a name="input_enabled_google_login"></a> [enabled\_google\_login](#input\_enabled\_google\_login) | Enable Google login, only one of Github App login or Google login can be enabled | `bool` | `false` | no |
| <a name="input_enabled_init_scripts"></a> [enabled\_init\_scripts](#input\_enabled\_init\_scripts) | Enable init scripts | `bool` | `true` | no |
| <a name="input_enabled_slack_notification"></a> [enabled\_slack\_notification](#input\_enabled\_slack\_notification) | Enable Slack notification | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_general_secrets"></a> [general\_secrets](#input\_general\_secrets) | Secrets are shared across all repos | `map(string)` | n/a | yes |
| <a name="input_github_app_credential_id"></a> [github\_app\_credential\_id](#input\_github\_app\_credential\_id) | GitHub App credentials key for jenkins | `string` | `"github-credentials"` | no |
| <a name="input_github_app_oauth_client_id"></a> [github\_app\_oauth\_client\_id](#input\_github\_app\_oauth\_client\_id) | The Client ID of Spartan SSO | `string` | `""` | no |
| <a name="input_github_app_oauth_client_secret"></a> [github\_app\_oauth\_client\_secret](#input\_github\_app\_oauth\_client\_secret) | The Client Secret of Spartan SSO | `string` | `""` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | The Github org name | `string` | n/a | yes |
| <a name="input_github_org_display_name"></a> [github\_org\_display\_name](#input\_github\_org\_display\_name) | The Github org display name. There should be no whitespaces within. | `string` | n/a | yes |
| <a name="input_google_oauth_client_id"></a> [google\_oauth\_client\_id](#input\_google\_oauth\_client\_id) | The Client ID of Google SSO | `string` | `""` | no |
| <a name="input_google_oauth_client_secret"></a> [google\_oauth\_client\_secret](#input\_google\_oauth\_client\_secret) | The Client Secret of Google SSO | `string` | `""` | no |
| <a name="input_google_user_list"></a> [google\_user\_list](#input\_google\_user\_list) | List users and roles for accessing Jenkins | `map(list(string))` | `null` | no |
| <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name) | The ingress class name of Jenkins ingress | `string` | `"alb"` | no |
| <a name="input_ingress_group_name"></a> [ingress\_group\_name](#input\_ingress\_group\_name) | The ingress group name of Jenkins ingress | `string` | `"external"` | no |
| <a name="input_install_plugins"></a> [install\_plugins](#input\_install\_plugins) | List of Jenkins plugins to install | `list(string)` | <pre>[<br/>  "configuration-as-code:1932.v75cb_b_f1b_698d",<br/>  "git:5.7.0",<br/>  "kubernetes:4306.vc91e951ea_eb_d",<br/>  "workflow-aggregator:600.vb_57cdd26fdd7"<br/>]</pre> | no |
| <a name="input_jenkins_admins"></a> [jenkins\_admins](#input\_jenkins\_admins) | List of Jenkins admins | `list(string)` | `[]` | no |
| <a name="input_jenkins_base_agent_image_name"></a> [jenkins\_base\_agent\_image\_name](#input\_jenkins\_base\_agent\_image\_name) | The base image for Jenkins agents | `string` | n/a | yes |
| <a name="input_jenkins_base_agent_image_repo"></a> [jenkins\_base\_agent\_image\_repo](#input\_jenkins\_base\_agent\_image\_repo) | The base image for Jenkins agents | `string` | n/a | yes |
| <a name="input_jenkins_base_agent_image_tag"></a> [jenkins\_base\_agent\_image\_tag](#input\_jenkins\_base\_agent\_image\_tag) | The base image for Jenkins agents | `string` | n/a | yes |
| <a name="input_jenkins_config_map_name"></a> [jenkins\_config\_map\_name](#input\_jenkins\_config\_map\_name) | Jenkins config map name | `string` | `null` | no |
| <a name="input_jenkins_cpu"></a> [jenkins\_cpu](#input\_jenkins\_cpu) | The CPU request and limit for Jenkins | `string` | `"1950m"` | no |
| <a name="input_jenkins_dns_name"></a> [jenkins\_dns\_name](#input\_jenkins\_dns\_name) | The Jenkins DNS name | `string` | `"jenkins"` | no |
| <a name="input_jenkins_env_var"></a> [jenkins\_env\_var](#input\_jenkins\_env\_var) | Jenkins environment variables | `string` | `null` | no |
| <a name="input_jenkins_executors"></a> [jenkins\_executors](#input\_jenkins\_executors) | List of Jenkins executors | `list(string)` | `[]` | no |
| <a name="input_jenkins_fqdn"></a> [jenkins\_fqdn](#input\_jenkins\_fqdn) | FQDN of Jenkins service | `string` | `""` | no |
| <a name="input_jenkins_memory"></a> [jenkins\_memory](#input\_jenkins\_memory) | The memory request and limit for Jenkins | `string` | `"4.5Gi"` | no |
| <a name="input_jenkins_shared_lib_repo"></a> [jenkins\_shared\_lib\_repo](#input\_jenkins\_shared\_lib\_repo) | The Jenkins shared library repo | `string` | n/a | yes |
| <a name="input_jenkins_viewer"></a> [jenkins\_viewer](#input\_jenkins\_viewer) | List of Jenkins viewer | `list(string)` | `[]` | no |
| <a name="input_kaniko_version"></a> [kaniko\_version](#input\_kaniko\_version) | Version of Kaniko build tool | `string` | `"v1.21.1"` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"jenkins"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to install Jenkins. Default is jenkins | `string` | `"jenkins"` | no |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector) | Map of labels to force pods onto Fargate nodes | `map(string)` | `{}` | no |
| <a name="input_nodejs_configuration"></a> [nodejs\_configuration](#input\_nodejs\_configuration) | To custom and define NodeJS values | <pre>object({<br/>    name    = string<br/>    version = string<br/>  })</pre> | <pre>{<br/>  "name": "Node 20",<br/>  "version": "20.10.0"<br/>}</pre> | no |
| <a name="input_shared_lib_name"></a> [shared\_lib\_name](#input\_shared\_lib\_name) | The name Jenkins uses to name the shared library | `string` | `"spartan"` | no |
| <a name="input_slack_bot_token"></a> [slack\_bot\_token](#input\_slack\_bot\_token) | The slack bot token | `string` | `null` | no |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations) | List of tolerations required to schedule onto Fargate nodes | <pre>list(object({<br/>    key      = string<br/>    operator = string<br/>    value    = string<br/>    effect   = string<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
