# Cloudwatch logging sub-module

Terraform Cloudwatch logging module for fargate.

## Usage

### Create Datadog RBAC

```hcl
module "cloudwatch_logging" {
  source  = "c0x12c/eks-cloudwatch-logging-fargate/aws"

  name                                    = local.cluster_name
  region                                  = local.region
  fargate_profile_pod_execution_role_name = module.fargate_profile.fargate_profile_pod_execution_role_name
}
```

## Examples

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                         | Version   |
|------------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)    | >= 1.9.8  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                      | >= 5.75   |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.33.0 |

## Providers

| Name                                                                   | Version   |
|------------------------------------------------------------------------|-----------|
| <a name="provider_aws"></a> [aws](#provider\_aws)                      | >= 5.75   |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.33.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                        | Type        |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_policy.fluent_bit_eks_fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                             | resource    |
| [aws_iam_role_policy_attachment.fargate_fluent_bit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [kubernetes_config_map.aws_logging](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                          | resource    |
| [kubernetes_namespace.aws_observability](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace)                      | resource    |
| [aws_iam_policy_document.fluent_bit_eks_fargate_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                 | data source |

## Inputs

| Name                                                                                                                                                              | Description                                                                 | Type     | Default | Required |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|----------|---------|:--------:|
| <a name="input_fargate_profile_pod_execution_role_name"></a> [fargate\_profile\_pod\_execution\_role\_name](#input\_fargate\_profile\_pod\_execution\_role\_name) | The name of the IAM role used by Fargate to execute pods in the EKS cluster | `string` | n/a     |   yes    |
| <a name="input_name"></a> [name](#input\_name)                                                                                                                    | Name of the resources will be created                                       | `string` | n/a     |   yes    |
| <a name="input_region"></a> [region](#input\_region)                                                                                                              | Region where the resources will be created                                  | `string` | `null`  |    no    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
