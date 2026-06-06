# Terraform Google Service Account Module

This Terraform module creates a GCP Service Account.

## Usage

### Create GCP Service Account

```hcl
module "service_account" {
  source  = "c0x12c/service-account/gcp"
  version = "1.0.0"
  
  service_account_id         = "example"
  disabled_service_account   = false
  enabled_create_custom_role = true
  permissions = [
    "storage.buckets.get",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
  ]
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
| [google_project_iam_custom_role.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.custom_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | A text description of the service bot service account. Must be less than or equal to 256 UTF-8 bytes. | `string` | `null` | no |
| <a name="input_disabled_service_account"></a> [disabled\_service\_account](#input\_disabled\_service\_account) | Whether the service account is disabled or not. | `string` | `false` | no |
| <a name="input_enabled_create_custom_role"></a> [enabled\_create\_custom\_role](#input\_enabled\_create\_custom\_role) | Whether to create a custom role or not. | `bool` | `false` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | A list of permissions granted to service account. | `list(string)` | `[]` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | A list of roles granted to service account. | `list(string)` | `[]` | no |
| <a name="input_service_account_display_name"></a> [service\_account\_display\_name](#input\_service\_account\_display\_name) | The display name for the service bot service account. | `string` | `null` | no |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | The account ID that is used to generate service account email address and a stable unique id. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_email"></a> [client\_email](#output\_client\_email) | The service account email address. |
| <a name="output_service_account_id"></a> [service\_account\_id](#output\_service\_account\_id) | The service account id. |
| <a name="output_service_account_key"></a> [service\_account\_key](#output\_service\_account\_key) | The private key in JSON format, base64 encoded. |
| <a name="output_service_account_key_id"></a> [service\_account\_key\_id](#output\_service\_account\_key\_id) | An identifier for the service account key with format projects/{{project}}/serviceAccounts/{{account}}/keys/{{key}}. |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | The service account name. |

<!-- END_TF_DOCS -->
