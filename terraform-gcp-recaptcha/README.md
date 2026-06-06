# Terraform Google Project Service Module

This Terraform module allows management of a single API service for a Google Cloud project.

## Usage

### Create Google Project Service

```hcl
module "recaptcha" {
  source  = "c0x12c/recaptcha/gcp"
  version = "~> 1.0.0"

  environment = "dev"

  # Android settings
  allow_all_package_names = false
  allowed_package_names   = ["com.example.app.dev"]

  #iOS settings
  allow_all_bundle_ids = false
  allowed_bundle_ids   = ["dev.example.app"]
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_recaptcha_enterprise_key.android](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/recaptcha_enterprise_key) | resource |
| [google_recaptcha_enterprise_key.ios](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/recaptcha_enterprise_key) | resource |
| [google_client_config.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_all_bundle_ids"></a> [allow\_all\_bundle\_ids](#input\_allow\_all\_bundle\_ids) | iOS settings. If set to true, it means allowed\_bundle\_ids will not be enforced. | `bool` | `true` | no |
| <a name="input_allow_all_package_names"></a> [allow\_all\_package\_names](#input\_allow\_all\_package\_names) | Android settings. If set to true, it means allowed\_package\_names will not be enforced. | `bool` | `true` | no |
| <a name="input_allowed_bundle_ids"></a> [allowed\_bundle\_ids](#input\_allowed\_bundle\_ids) | iOS settings. iOS bundle ids of apps allowed to use the key. Example: 'com.companyname.productname.appname'. | `list(string)` | `[]` | no |
| <a name="input_allowed_package_names"></a> [allowed\_package\_names](#input\_allowed\_package\_names) | Android settings. Android package names of apps allowed to use the key. Example: 'com.companyname.appname'. | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment where the resources will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_android_key_id"></a> [android\_key\_id](#output\_android\_key\_id) | n/a |
| <a name="output_ios_key_id"></a> [ios\_key\_id](#output\_ios\_key\_id) | n/a |

<!-- END_TF_DOCS -->
