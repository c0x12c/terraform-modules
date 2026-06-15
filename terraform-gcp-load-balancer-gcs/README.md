# Terraform Load Balancer GCS Module

This Terraform module allows management of Load Balancer in front of Google Cloud Storage.

## Usage

### Create Load Balancer GCS

```hcl
module "load_balancer" {
  source  = "terraform.c0x12c.com/c0x12c/load-balancer-gcs/gcp"
  version = "1.0.1"

  prefix_name = "proj-x"
  bucket_name = "proj-x-static-website"
  enable_http = true
  enable_ssl  = false
  enable_cdn  = true
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
| [google_compute_backend_bucket.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_bucket) | resource |
| [google_compute_global_address.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_forwarding_rule.http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_global_forwarding_rule.https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_managed_ssl_certificate.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate) | resource |
| [google_compute_target_http_proxy.http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy) | resource |
| [google_compute_target_https_proxy.https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_url_map.bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of Backend bucket. | `string` | `null` | no |
| <a name="input_certificate_map"></a> [certificate\_map](#input\_certificate\_map) | Certificate map to use for the load balancer. | `string` | `null` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domains for which a managed SSL certificate will be valid. | `string` | `null` | no |
| <a name="input_enable_cdn"></a> [enable\_cdn](#input\_enable\_cdn) | If true, enable Cloud CDN for this BackendBucket. | `bool` | `true` | no |
| <a name="input_enable_http"></a> [enable\_http](#input\_enable\_http) | If true, enable HTTP for this BackendBucket. | `bool` | `true` | no |
| <a name="input_enable_ssl"></a> [enable\_ssl](#input\_enable\_ssl) | If true, enable SSL for this BackendBucket. | `bool` | `true` | no |
| <a name="input_prefix_name"></a> [prefix\_name](#input\_prefix\_name) | Prefix for all resources created by this module. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | n/a |
| <a name="output_lb_name"></a> [lb\_name](#output\_lb\_name) | n/a |

<!-- END_TF_DOCS -->
