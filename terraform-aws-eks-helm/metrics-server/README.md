# EKS-Helm/Metrics-Server

This module helps install and configure Metrics Server for EKS cluster via Helm chart.

## Usage

### Install Metrics Server

```hcl
module "eks_helm_datadog" {
  source = "github.com/spartan-stratos/terraform-modules//aws/eks-helm/metrics-server?ref=v0.3.0"

  helm_release_name  = "metrics-server"
  namespace          = "kube-system"
  helm_chart_version = "3.12.2"

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

## Providers

| Name                                                 | Version  |
|------------------------------------------------------|----------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=2.16.1 |

## Modules

No modules.

## Resources

| Name                                                                                                                | Type     |
|---------------------------------------------------------------------------------------------------------------------|----------|
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name                                                                                         | Description                              | Type                | Default            | Required |
|----------------------------------------------------------------------------------------------|------------------------------------------|---------------------|--------------------|:--------:|
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version) | The chart version of ingress controller  | `string`            | `"3.12.2"`         |    no    |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name)    | The Helm release of the services.        | `string`            | `"metrics-server"` |    no    |
| <a name="input_namespace"></a> [namespace](#input\_namespace)                                | The Namespace of the services.           | `string`            | `"kube-system"`    |    no    |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector)                  | Node selector for the ingress controller | `map(string)`       | `{}`               |    no    |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations)                          | Tolerations for the ingress controller   | `list(map(string))` | `[]`               |    no    |

## Outputs

No outputs.
