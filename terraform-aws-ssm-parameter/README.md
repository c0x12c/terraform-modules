# AWS SSM parameter Terraform module

Terraform module which creates SSM parameter resources on AWS.

## Usage

### Create a static website

```hcl
module "ssm_parameter" {
  source  = "c0x12c/ssm-parameter/aws"
  version = "1.0.0"

  prefix = "example"
  parameters = {
    "key-1" = {
      value       = "example-1"
      description = "example 1 description"
      insecure    = false
    },
    "key-2" = {
      value       = "example-2"
      description = "example 2 description"
      insecure    = true
    },
    "key-3" = {
      values      = ["example-3"]
      description = "example 3 description"
      insecure    = false
    }
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
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Map of parameter stores, the key is name of this value | <pre>map(object({<br/>    # Value of the parameter.<br/>    value = optional(string, null)<br/>    # List of values of the parameter (will be jsonencoded to store as string natively in SSM).<br/>    values = optional(list(string), [])<br/>    # Description of the parameter.<br/>    description = optional(string, null)<br/>    # Enable insecure values <br/>    insecure = optional(bool, false)<br/>    # Parameter tier to assign to the parameter. If not specified, will use the default parameter tier for the region. Valid tiers are Standard, Advanced, and Intelligent-Tiering. Downgrading an Advanced tier parameter to Standard will recreate the resource.<br/>    tier = optional(string, "Standard")<br/>    # KMS key ID or ARN for encrypting a parameter (when type is SecureString)<br/>    key_id = optional(string, null)<br/>    # Regular expression used to validate the parameter value.<br/>    allowed_pattern = optional(string, null)<br/>    # Data type of the parameter. Valid values: text, aws:ssm:integration and aws:ec2:image for AMI format.<br/>    data_type = optional(string, "text")<br/>  }))</pre> | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix of list of parameters | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_parameter_arns"></a> [parameter\_arns](#output\_parameter\_arns) | List of parameter ARNs |
| <a name="output_parameter_ids"></a> [parameter\_ids](#output\_parameter\_ids) | List of parameter ids |
<!-- END_TF_DOCS -->
