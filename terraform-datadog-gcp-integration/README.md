# Datadog GCP integration module

Terraform module which creates Datadog GCP integration and service account resources on GCP.

## Usage

### Create Artifact Registry

```hcl
module "datadog_gcp_integration" {
  source  = "c0x12c/gcp-integration/datadog"
  version = "~> 1.1.0"

  datadog_account_id   = "datadog"
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.46 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | 3.67.0 |
| <a name="provider_google"></a> [google](#provider\_google) | 6.43.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_service_account"></a> [service\_account](#module\_service\_account) | c0x12c/service-account/gcp | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [datadog_integration_gcp_sts.this](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_gcp_sts) | resource |
| [google_service_account_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automute"></a> [automute](#input\_automute) | Determines whether to automatically mute monitors related to this integration during a downtime. Set to 'true' to enable automatic muting and 'false' to disable it. | `bool` | `true` | no |
| <a name="input_datadog_account_id"></a> [datadog\_account\_id](#input\_datadog\_account\_id) | The datadog account name to create. | `string` | n/a | yes |
| <a name="input_datadog_roles"></a> [datadog\_roles](#input\_datadog\_roles) | Datadog service account should have compute.viewer, monitoring.viewer, cloudasset.viewer, and browser roles (the browser role is only required in the default project of the service account). | `list(string)` | <pre>[<br/>  "roles/compute.viewer",<br/>  "roles/container.viewer",<br/>  "roles/monitoring.viewer",<br/>  "roles/cloudasset.viewer",<br/>  "roles/browser"<br/>]</pre> | no |
| <a name="input_enabled_services"></a> [enabled\_services](#input\_enabled\_services) | Values to enable GCP services in Datadog integration. | `list(string)` | <pre>[<br/>  "redis",<br/>  "memcache",<br/>  "cloudsql",<br/>  "dbinsights",<br/>  "kubernetes",<br/>  "loadbalancing",<br/>  "kubernetes"<br/>]</pre> | no |
| <a name="input_host_filters"></a> [host\_filters](#input\_host\_filters) | A string used to filter the hosts sent from GCP to Datadog. Only hosts matching the specified tags will be included. Tags should be in the format 'key:value' and multiple tags can be separated by commas (e.g., 'environment:production,datadog:true'). | `string` | `"datadog:true"` | no |
| <a name="input_is_cspm_enabled"></a> [is\_cspm\_enabled](#input\_is\_cspm\_enabled) | Indicates whether CSPM (Cloud Security Posture Management) is enabled in the Terraform configuration. Disable to save cost. | `bool` | `false` | no |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
