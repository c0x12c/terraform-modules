# Password generator module

Module which generates password then stores to Secret Manager.

## Usage

### Generate password

```hcl
module "password_generator" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/password-generator?ref=v0.2.0"

  secret_name = "secret"
  tags = {
    Name = "secret"
  }
}
```

## Examples

- [Example](./examples/complete/)

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
| [aws_secretsmanager_secret.password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.password_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_random_password.random_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_random_password) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_password_length"></a> [password\_length](#input\_password\_length) | The length of password to generate. | `number` | `32` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | The name of the secret | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_password_secret_id"></a> [password\_secret\_id](#output\_password\_secret\_id) | The password secret id |
<!-- END_TF_DOCS -->
