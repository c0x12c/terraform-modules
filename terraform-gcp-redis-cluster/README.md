# Terraform Google Redis Cluster Module

This Terraform module creates a GCP redis cluster.

## Usage

### Create GCP Redis cluter

```hcl
module "redis_cluster" {
  source  = "terraform.c0x12c.com/c0x12c/redis-cluster/gcp"
  version = "0.1.4"

  name   = "redis-cluster-name"
  region = "us-west1"
  vpc_id = "example-vpc-id"

  node_type               = "REDIS_SHARED_CORE_NANO"
  authorization_mode      = "AUTH_MODE_DISABLED"
  transit_encryption_mode = "TRANSIT_ENCRYPTION_MODE_DISABLED"
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
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_redis_cluster.this](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_redis_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorization_mode"></a> [authorization\_mode](#input\_authorization\_mode) | The authorization mode of the Redis cluster. If not provided, auth feature is disabled for the cluster. Default value is AUTH\_MODE\_DISABLED. Possible values are: AUTH\_MODE\_UNSPECIFIED, AUTH\_MODE\_IAM\_AUTH, AUTH\_MODE\_DISABLED. | `string` | `"AUTH_MODE_DISABLED"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of redis cluster to create. | `string` | n/a | yes |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | The node type for the Redis cluster. Possible values are: REDIS\_SHARED\_CORE\_NANO, REDIS\_HIGHMEM\_MEDIUM, REDIS\_HIGHMEM\_XLARGE, REDIS\_STANDARD\_SMALL. | `string` | `"REDIS_HIGHMEM_MEDIUM"` | no |
| <a name="input_region"></a> [region](#input\_region) | The GCP region in which the resources are created. | `string` | n/a | yes |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | The number of replica nodes per shard. | `number` | `1` | no |
| <a name="input_shard_count"></a> [shard\_count](#input\_shard\_count) | The number of shards to for redis cluster. | `number` | `3` | no |
| <a name="input_transit_encryption_mode"></a> [transit\_encryption\_mode](#input\_transit\_encryption\_mode) | The in-transit encryption for the Redis cluster. If not provided, encryption is disabled for the cluster. Default value is TRANSIT\_ENCRYPTION\_MODE\_DISABLED. Possible values are: TRANSIT\_ENCRYPTION\_MODE\_UNSPECIFIED, TRANSIT\_ENCRYPTION\_MODE\_DISABLED, TRANSIT\_ENCRYPTION\_MODE\_SERVER\_AUTHENTICATION. | `string` | `"TRANSIT_ENCRYPTION_MODE_DISABLED"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of VPC in which the resources are created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_host"></a> [host](#output\_host) | The connection endpoint for the Redis cluster, combining the address and port of the first discovery endpoint. |
<!-- END_TF_DOCS -->
