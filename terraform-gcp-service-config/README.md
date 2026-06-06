# Terraform Google Service Config Module

This Terraform module creates a combination of resources (customizable and optional config) for k8s service:

- Creates DNS resources including managed zone and DNS record.
- Creates K8S configmap and secrets.
- Create service account with either custom role or predefined list of roles.

## Usage

### Create GCP Service config

```hcl
module "service" {
  source  = "c0x12c/service-config/gcp"
  version = "~> 1.0.0"

  environment = "dev"
  name        = "service"
  namespace   = "example"
  create_namespace = true

  roles = [
    "roles/bigquery.dataViewer"
  ]

  hostname = "service"
  domain_name = "example.com"
  managed_zone = "example-zone"
  dns_rrdatas = ["alias"]
  dns_ttl = 300
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
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.34.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.34.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns"></a> [dns](#module\_dns) | c0x12c/cloud-dns/gcp | ~> 0.1.4 |
| <a name="module_service_account"></a> [service\_account](#module\_service\_account) | c0x12c/service-account/gcp | ~> 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map.applications_config_map](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.applications_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_map"></a> [config\_map](#input\_config\_map) | The map of configmap. | `map(any)` | `{}` | no |
| <a name="input_create_custom_role"></a> [create\_custom\_role](#input\_create\_custom\_role) | Whether to create a custom role or not. If set to `true`, it will grant `roles` to service account, else, it will create custom role with `permissions`. | `bool` | `false` | no |
| <a name="input_create_dns_zone"></a> [create\_dns\_zone](#input\_create\_dns\_zone) | Specifies whether to create DNS zone. If set to `false`, it will create DNS records using existing `managed_zone`. | `bool` | `false` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Specifies whether to create a namespace. If set to `false`, it will create resources using existing `namespace`. | `bool` | `true` | no |
| <a name="input_dns_rrdatas"></a> [dns\_rrdatas](#input\_dns\_rrdatas) | The DNS record `rrdatas` refers to the data associated with a DNS record, allowing for the correct mapping and routing of network traffic based on DNS resolution. | `list(string)` | `[]` | no |
| <a name="input_dns_ttl"></a> [dns\_ttl](#input\_dns\_ttl) | The DNS record TTL (Time To Live) time in seconds. | `number` | `300` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name. Should be non-nullable if `managed_zone` differentiates from `null`. | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment to create associating resources. | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | The hostname or subdomain name to create DNS record for associating service. Should be non-nullable if `managed_zone` differentiates from `null`. | `string` | `null` | no |
| <a name="input_managed_zone"></a> [managed\_zone](#input\_managed\_zone) | The GCP zone name associating with `domain_name`. If set to `null`, no DNS records are created. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The service name that is used to name the associating configmap, secret and service account. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace to create k8s secrets and configmap. | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | A list of permissions granted to service account. | `list(string)` | `[]` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | A list of roles granted to service account. | `list(string)` | `[]` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | The map of secrets. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_record_name"></a> [dns\_record\_name](#output\_dns\_record\_name) | The list of DNS record names. |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | The service account email. |
| <a name="output_service_account_key"></a> [service\_account\_key](#output\_service\_account\_key) | The service account key. |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | The service account name. |

<!-- END_TF_DOCS -->
