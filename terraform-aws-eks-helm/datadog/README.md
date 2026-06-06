# EKS-Helm/Datadog

This module helps install and configure Datadog agents for EKS cluster via Helm chart.

## Usage

### Install Datadog

```hcl
module "eks_helm_datadog" {
  source = "github.com/spartan-stratos/terraform-modules//aws/eks-helm/datadog?ref=v0.3.0"

  cluster_name    = "my-eks-cluster"
  namespace       = "datadog"
  datadog_api_key = "YOUR_SUPER_SECRET_API_KEY"
  datadog_app_key = "YOUR_SUPER_SECRET_APP_KEY"
  environment     = "DEV"
  datadog_site    = "datadoghq.com"
  datadog_envs = [
    {
      name  = "DD_APM_ENABLED"
      value = "true"
    }
  ]
  node_selector = {}
  tolerations = []
}

```

## Examples

- [Example](./examples/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm)                | >=2.16.1 |
| <a name="requirement_random"></a> [random](#requirement\_random)          | >=3.6    |

## Providers

| Name                                                       | Version  |
|------------------------------------------------------------|----------|
| <a name="provider_helm"></a> [helm](#provider\_helm)       | >=2.16.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.6    |

## Modules

No modules.

## Resources

| Name                                                                                                                           | Type     |
|--------------------------------------------------------------------------------------------------------------------------------|----------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                      | resource |
| [random_password.cluster_agent_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name                                                                                                                                             | Description                                      | Type                                                                             | Default     | Required |
|--------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------|----------------------------------------------------------------------------------|-------------|:--------:|
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version)                                                                      | The version of the datadog chart                 | `string`                                                                         | `"3.88.2"`  |    no    |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)                                                                         | The EKS cluster name                             | `string`                                                                         | n/a         |   yes    |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key)                                                              | The datadog api key                              | `string`                                                                         | n/a         |   yes    |
| <a name="input_datadog_app_key"></a> [datadog\_app\_key](#input\_datadog\_app\_key)                                                              | The datadog app key                              | `string`                                                                         | n/a         |   yes    |
| <a name="input_datadog_envs"></a> [datadog\_envs](#input\_datadog\_envs)                                                                         | Environment variables for datadog agents         | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]`        |    no    |
| <a name="input_datadog_site"></a> [datadog\_site](#input\_datadog\_site)                                                                         | The datadog site                                 | `string`                                                                         | n/a         |   yes    |
| <a name="input_enabled_agent"></a> [enabled\_agent](#input\_enabled\_agent)                                                                      | Toggle to enable or disable the agent.           | `bool`                                                                           | `false`     |    no    |
| <a name="input_enabled_cluster_agent"></a> [enabled\_cluster\_agent](#input\_enabled\_cluster\_agent)                                            | Toggle to enable or disable the cluster agent.   | `bool`                                                                           | `true`      |    no    |
| <a name="input_enabled_cluster_check"></a> [enabled\_cluster\_check](#input\_enabled\_cluster\_check)                                            | Toggle to enable or disable the cluster check.   | `bool`                                                                           | `true`      |    no    |
| <a name="input_enabled_container_collect_all_logs"></a> [enabled\_container\_collect\_all\_logs](#input\_enabled\_container\_collect\_all\_logs) | Toggle to enable or disable the container logs.  | `bool`                                                                           | `true`      |    no    |
| <a name="input_enabled_logs"></a> [enabled\_logs](#input\_enabled\_logs)                                                                         | Toggle to enable or disable the logs.            | `bool`                                                                           | `true`      |    no    |
| <a name="input_enabled_metric_provider"></a> [enabled\_metric\_provider](#input\_enabled\_metric\_provider)                                      | Toggle to enable or disable the metric provider. | `bool`                                                                           | `true`      |    no    |
| <a name="input_environment"></a> [environment](#input\_environment)                                                                              | Environment where the resources will be created. | `string`                                                                         | n/a         |   yes    |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name)                                                        | The Helm release of the services.                | `string`                                                                         | `"datadog"` |    no    |
| <a name="input_http_check_urls"></a> [http\_check\_urls](#input\_http\_check\_urls)                                                              | The list of urls for http check                  | `list(string)`                                                                   | `[]`        |    no    |
| <a name="input_namespace"></a> [namespace](#input\_namespace)                                                                                    | The Namespace of the services.                   | `string`                                                                         | `"datadog"` |    no    |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector)                                                                      | Node selector for the ingress controller         | `map(string)`                                                                    | `{}`        |    no    |
| <a name="input_timeout"></a> [timeout](#input\_timeout)                                                                                          | Default timeout of datadog                       | `number`                                                                         | `1200`      |    no    |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations)                                                                              | Tolerations for the ingress controller           | `list(map(string))`                                                              | `[]`        |    no    |

## Outputs

| Name                                                                                                               | Description                          |
|--------------------------------------------------------------------------------------------------------------------|--------------------------------------|
| <a name="output_cluster_agent_auth_token"></a> [cluster\_agent\_auth\_token](#output\_cluster\_agent\_auth\_token) | The auth token for the cluster agent |

<!-- END_TF_DOCS -->
