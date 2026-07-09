# AWS DocumentDB Terraform module

Terraform module which provisions an Amazon DocumentDB (MongoDB-compatible) cluster on AWS.

## Features

- DocumentDB cluster with a configurable number of instances (single-node by default)
- Randomly generated master password (or bring your own), stored with the connection
  details in AWS Secrets Manager as a ready-to-use MongoDB URI
- Security group ingress via SG-to-SG references and/or CIDR blocks (port 27017)
- Cluster parameter group with a `tls` toggle and passthrough for extra parameters
- Storage encryption, backup retention, deletion protection, and CloudWatch log exports

## Usage

```hcl
module "documentdb" {
  source  = "terraform.c0x12c.com/c0x12c/documentdb/aws"
  version = "~> 0.1"

  name            = "growthbook-dev"
  master_username = "growthbook"
  database_name   = "growthbook"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.database_subnet_ids

  instance_class = "db.t3.medium"
  instance_count = 1
  tls_enabled    = true

  security_group_rules = {
    eks         = { source_security_group_id = module.eks.worker_sg_id }
    eks_cluster = { source_security_group_id = module.eks.cluster_security_group_id }
  }

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  tags = { Environment = "dev" }
}
```

## Operational notes

- **Connection secret.** When `create_secret = true` (default) the module writes a
  Secrets Manager secret named `<name>-connection` containing `host`, `port`, `username`,
  `password`, `database`, `tls`, and a ready-to-use `uri`. Consumers (e.g. an
  external-secrets `ExternalSecret`) read the `uri` key directly.
- **TLS.** Enabled by default. Clients must present the
  [Amazon RDS global CA bundle](https://docs.aws.amazon.com/documentdb/latest/developerguide/security.encryption.ssl.html)
  and connect with `tls=true` (already set in the emitted URI). Set `tls_enabled = false`
  to drop the requirement in throwaway environments.
- **Minimal instance size.** `db.t3.medium` is the smallest DocumentDB instance class.
- **Deletion protection** defaults to `true`. Flip it to `false` (and set
  `skip_final_snapshot = true` if desired) before a destroy.

## Examples

See [`examples/complete`](examples/complete) for a runnable example.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.54.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_docdb_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster) | resource |
| [aws_docdb_cluster_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_instance) | resource |
| [aws_docdb_cluster_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_parameter_group) | resource |
| [aws_docdb_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_subnet_group) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.from_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.from_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_id.snapshot_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Whether major engine version upgrades are allowed. | `bool` | `false` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether to apply changes immediately, instead of waiting for the next maintenance window. | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Whether minor engine upgrades are applied automatically during the maintenance window. | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to retain automated backups. | `number` | `1` | no |
| <a name="input_create_db_cluster_parameter_group"></a> [create\_db\_cluster\_parameter\_group](#input\_create\_db\_cluster\_parameter\_group) | Whether to create a DB cluster parameter group. Set false to bring your own. | `bool` | `true` | no |
| <a name="input_create_db_subnet_group"></a> [create\_db\_subnet\_group](#input\_create\_db\_subnet\_group) | Whether to create a DB subnet group from `subnets`. Set false to bring your own. | `bool` | `true` | no |
| <a name="input_create_secret"></a> [create\_secret](#input\_create\_secret) | Whether to store the connection details (host, port, credentials, URI) in a Secrets Manager secret. | `bool` | `true` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Database name used in the connection URI path. DocumentDB creates databases lazily, so this only shapes the URI. If null, the URI has an empty path. | `string` | `null` | no |
| <a name="input_db_cluster_parameter_group_family"></a> [db\_cluster\_parameter\_group\_family](#input\_db\_cluster\_parameter\_group\_family) | Family for the cluster parameter group (e.g. docdb5.0). | `string` | `"docdb5.0"` | no |
| <a name="input_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#input\_db\_cluster\_parameter\_group\_name) | Name of an existing cluster parameter group to use when create\_db\_cluster\_parameter\_group is false. | `string` | `null` | no |
| <a name="input_db_cluster_parameter_group_parameters"></a> [db\_cluster\_parameter\_group\_parameters](#input\_db\_cluster\_parameter\_group\_parameters) | Additional parameters to set on the cluster parameter group (the `tls` parameter is managed via tls\_enabled). | <pre>list(object({<br/>    name         = string<br/>    value        = string<br/>    apply_method = optional(string, "pending-reboot")<br/>  }))</pre> | `[]` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | Name of an existing DB subnet group to use (when create\_db\_subnet\_group is false), or override name when creating. | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether deletion protection is enabled. Defaults to true; must be flipped to false before a destroy. | `bool` | `true` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | List of log types to export to CloudWatch Logs (e.g. audit, profiler). | `list(string)` | `[]` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | DocumentDB engine version. | `string` | `"5.0.0"` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Instance class for the DocumentDB cluster instances. | `string` | `"db.t3.medium"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of cluster instances to create. 1 is the minimal single-node setup; add more for HA. | `number` | `1` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN of the KMS key used for storage encryption. If null, the default DocumentDB-managed key is used. | `string` | `null` | no |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | Master DB password. If null, a random password is generated and stored in the connection secret. | `string` | `null` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Username for the master DB user. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The cluster identifier and base name for related resources (subnet group, security group, parameter group, instances). | `string` | n/a | yes |
| <a name="input_password_length"></a> [password\_length](#input\_password\_length) | Length of the generated master password when master\_password is null. | `number` | `32` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | Daily UTC window when automated backups are taken (HH:MM-HH:MM). | `string` | `"03:00-04:00"` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | Weekly UTC window for system maintenance (ddd:HH:MM-ddd:HH:MM). | `string` | `"sun:04:00-sun:05:00"` | no |
| <a name="input_secret_kms_key_id"></a> [secret\_kms\_key\_id](#input\_secret\_kms\_key\_id) | KMS key ID used to encrypt the connection secret. Defaults to aws/secretsmanager. | `string` | `null` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Name of the Secrets Manager secret. Defaults to `<name>-connection`. | `string` | `null` | no |
| <a name="input_secret_recovery_window_in_days"></a> [secret\_recovery\_window\_in\_days](#input\_secret\_recovery\_window\_in\_days) | Recovery window for the Secrets Manager secret. 0 forces immediate deletion (useful in dev). | `number` | `7` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Map of ingress rules for the cluster security group. Each value may set source\_security\_group\_id (preferred for VPC services) and/or cidr\_blocks. from\_port/to\_port default to the DocumentDB port (27017). | <pre>map(object({<br/>    source_security_group_id = optional(string)<br/>    cidr_blocks              = optional(list(string))<br/>    description              = optional(string)<br/>    from_port                = optional(number)<br/>    to_port                  = optional(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Whether to skip the final snapshot before destroying the cluster. | `bool` | `false` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Whether the cluster storage is encrypted. | `bool` | `true` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnet IDs for the DB subnet group. Required when create\_db\_subnet\_group is true. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all created resources. | `map(string)` | `{}` | no |
| <a name="input_tls_enabled"></a> [tls\_enabled](#input\_tls\_enabled) | Whether TLS is required for client connections. Sets the `tls` cluster parameter and shapes the connection URI. | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID in which the cluster will be deployed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The cluster ARN |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The cluster identifier |
| <a name="output_cluster_parameter_group_name"></a> [cluster\_parameter\_group\_name](#output\_cluster\_parameter\_group\_name) | Name of the cluster parameter group |
| <a name="output_cluster_resource_id"></a> [cluster\_resource\_id](#output\_cluster\_resource\_id) | The immutable resource ID of the cluster |
| <a name="output_connection_uri"></a> [connection\_uri](#output\_connection\_uri) | Ready-to-use MongoDB connection URI for the cluster |
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | Name of the DB subnet group used by the cluster |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The cluster (writer) endpoint |
| <a name="output_instances"></a> [instances](#output\_instances) | List of cluster instance identifiers and endpoints |
| <a name="output_master_username"></a> [master\_username](#output\_master\_username) | The master username |
| <a name="output_port"></a> [port](#output\_port) | Port the cluster accepts connections on |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | The load-balanced reader endpoint |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | ARN of the connection secret in Secrets Manager (when create\_secret is true) |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | Name of the connection secret in Secrets Manager (when create\_secret is true) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the cluster security group |
<!-- END_TF_DOCS -->

## References

- AWS provider docs: [aws_docdb_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster)
