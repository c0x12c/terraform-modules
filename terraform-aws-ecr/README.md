# Amazon ECR Terraform module

Terraform module which creates Amazon ECR resources.

## Usage

```hcl
module "ecr" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/acm?ref=v0.1.0"

  name = "example-repo"

  tags = {
    Name = "example-repo"
  }
}
```

## Examples

- [Example complete](./examples/complete/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_registry_scanning_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_registry_scanning_configuration) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_lifecycle_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_lifecycle_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled_ecr_scanning"></a> [enabled\_ecr\_scanning](#input\_enabled\_ecr\_scanning) | Enable ECR image scanning. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECR | `string` | n/a | yes |
| <a name="input_scan_frequency"></a> [scan\_frequency](#input\_scan\_frequency) | The frequency of the scan. Valid values: 'CONTINUOUS\_SCAN', 'SCAN\_ON\_PUSH', 'MANUAL' | `string` | `"SCAN_ON_PUSH"` | no |
| <a name="input_scan_type"></a> [scan\_type](#input\_scan\_type) | The type of scan to run. Valid values: 'BASIC', 'ENHANCED' | `string` | `"BASIC"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | Name of the repository |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | The URL of the repository |
<!-- END_TF_DOCS -->