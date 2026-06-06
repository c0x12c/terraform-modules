# AWS Identity SAML Provider module - Base module for AWS VPN CLIENT

Terraform module which creates Identity SAML Provider resource on AWS.

## Usage

### Create Identity SAML Provider

```hcl
module "saml_vpn" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/identity-provider/saml?ref=v0.1.0"

  saml_providers = {
    "example_provider" = "example_saml_metadata"
  }
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="provider_aws"></a> [aws](#provider\_aws)                         | \>= 5.75 |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | \>=5.75 |

## Modules

No modules.

## Resources

| Name                                                                                                                        | Type     |
|-----------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_iam_saml_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |

## Inputs

| Name                                                                           | Description                                                      | Type          | Default | Required |
|--------------------------------------------------------------------------------|------------------------------------------------------------------|---------------|---------|:--------:|
| <a name="input_saml_providers"></a> [saml\_providers](#input\_saml\_providers) | A map of SAML providers name and SAML metadata document content. | `map(string)` | n/a     |   yes    |

## Outputs

| Name                                                                                          | Description                              |
|-----------------------------------------------------------------------------------------------|------------------------------------------|
| <a name="output_saml_provider_arns"></a> [saml\_provider\_arns](#output\_saml\_provider_arns) | The map of SAML provider arn(s) created. |

<!-- END_TF_DOCS -->
