# EKS-Helm/OPA

This module helps install and configure OPA Engine for EKS cluster via Helm chart.

## Usage

### Install OPA Engine

```hcl
module "eks_helm_opa" {
  source = "github.com/spartan-stratos/terraform-modules//aws/eks-helm/opa?ref=v0.5.4"

  helm_release_name  = "opa"
  namespace          = "kube-system"
  helm_chart_version = "0.1.13"
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
| [helm_release.opa](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name                                                                                         | Description                              | Type                | Default            | Required |
|----------------------------------------------------------------------------------------------|------------------------------------------|---------------------|--------------------|:--------:|
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version) | The chart version of ingress controller  | `string`            | `"0.1.13"`         |    no    |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name)    | The Helm release of the services.        | `string`            | `"opa"` |    no    |
| <a name="input_namespace"></a> [namespace](#input\_namespace)                                | The Namespace of the services.           | `string`            | `"opa"`    |    no    |
| <a name="input_opa_image_tag"></a> [opa\_image\_tag](#input\_opa\_image\_tag)                                | The tag of the OPA docker image           | `string`            | `"1.4.2"`    |    no    |
| <a name="create_namespace"></a> [create\_namespace](#input\_create\_namespace)                                | Create the namespace if it does not yet exist.           | `bool`            | `true`    |    no    |

## Outputs

No outputs.
