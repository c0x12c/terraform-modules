# GKE Gateway API Terraform module

This Terraform module provisions a Google Kubernetes Engine (GKE) Gateway API with configurable options.

## Usage

### Create GKE Gateway API

```hcl
module "gke_autopilot" {
  source  = "c0x12c/gke-gateway-api/gcp"
  version = "~> 1.0.0"

  ext_gateway_name = "external-gateway"
  create_namespace = true
  cert_map         = "<cert-name>"
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.34 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.34 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.external_gateway](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.gateway_api](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [time_sleep.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [kubernetes_resource.external_gateway](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/resource) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_map"></a> [cert\_map](#input\_cert\_map) | The Google-managed SSL certificate name used to secure GKE gateway, reference: `https://cloud.google.com/kubernetes-engine/docs/how-to/secure-gateway#secure-using-ssl-certificate`. | `string` | n/a | yes |
| <a name="input_create_duration"></a> [create\_duration](#input\_create\_duration) | Specifies time to wait for resource creation. | `string` | `"300s"` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Specifies whether to create a new namespace. | `bool` | `true` | no |
| <a name="input_enabled_field_manager"></a> [enabled\_field\_manager](#input\_enabled\_field\_manager) | Specifies whether to enable field manager for the resource. | `bool` | `false` | no |
| <a name="input_ext_gateway_class_name"></a> [ext\_gateway\_class\_name](#input\_ext\_gateway\_class\_name) | The gateway class name, reference: `https://cloud.google.com/kubernetes-engine/docs/how-to/gatewayclass-capabilities`. | `string` | `"gke-l7-global-external-managed"` | no |
| <a name="input_ext_gateway_name"></a> [ext\_gateway\_name](#input\_ext\_gateway\_name) | The gateway name to be created. | `string` | `"external-gateway"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace name to create gateway within. | `string` | `"gateway-api"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ext_gateway_address"></a> [ext\_gateway\_address](#output\_ext\_gateway\_address) | The external IP address of the external gateway resource. |

<!-- END_TF_DOCS -->
