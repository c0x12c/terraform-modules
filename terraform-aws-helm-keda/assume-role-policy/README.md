# AWS EKS Keda Assume Role Policy Terraform Module

This Terraform module is used to attach the assume role arns to kera-operator role.

## Usage

### Create the Keda Assume Role Policy

```hcl
module "keda" {
  source = "github.com/spartan-stratos/terraform-modules//aws/eks-helm/keda/assume-role-policy?ref=v0.1.60"

  keda_operator_role_id = "keda-operator"
  assume_role_arns = [
    "arn:aws:iam::000000000000:role/service-platform-eksPodRole"
  ]
}

```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version   |
|---------------------------------------------------------------------------|-----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 5.75.0 |

## Providers

| Name                                              | Version   |
|---------------------------------------------------|-----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                               | Type        |
|------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)            | resource    |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name                                                                                                    | Description                                                                       | Type           | Default | Required |
|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_assume_role_arns"></a> [assume\_role\_arns](#input\_assume\_role\_arns)                  | A list of ARNs that Keda will use to assume the IAM role to access AWS resources. | `list(string)` | `[]`    |    no    |
| <a name="input_keda_operator_role_id"></a> [keda\_operator\_role\_id](#input\_keda\_operator\_role\_id) | The ID of the IAM role that Keda will use to access AWS resources.                | `string`       | n/a     |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
