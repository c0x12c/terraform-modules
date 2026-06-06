<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_qdrant-cloud"></a> [qdrant-cloud](#requirement\_qdrant-cloud) | >=1.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_qdrant-cloud"></a> [qdrant-cloud](#provider\_qdrant-cloud) | 1.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [qdrant-cloud_accounts_cluster.this](https://registry.terraform.io/providers/qdrant/qdrant-cloud/latest/docs/resources/accounts_cluster) | resource |
| [qdrant-cloud_accounts_database_api_key_v2.this](https://registry.terraform.io/providers/qdrant/qdrant-cloud/latest/docs/resources/accounts_database_api_key_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | Cloud provider to use for the Qdrant cluster | `string` | `"aws"` | no |
| <a name="input_name"></a> [name](#input\_name) | Qdrant cluster name | `string` | n/a | yes |
| <a name="input_node_package_id"></a> [node\_package\_id](#input\_node\_package\_id) | Node package ID to use for the Qdrant cluster | `string` | n/a | yes |
| <a name="input_number_of_nodes"></a> [number\_of\_nodes](#input\_number\_of\_nodes) | Number of nodes in the Qdrant cluster | `number` | `1` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy the Qdrant cluster | `string` | `"us-west-2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of the Qdrant cluster. |
| <a name="output_token"></a> [token](#output\_token) | Token to authenticate with the Qdrant cluster. |
| <a name="output_url"></a> [url](#output\_url) | URL to access the Qdrant cluster. |
<!-- END_TF_DOCS -->