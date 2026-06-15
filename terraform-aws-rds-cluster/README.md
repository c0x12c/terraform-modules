# AWS RDS Cluster Terraform module

Terraform module which provisions an Amazon RDS cluster on AWS. A single module supports both **Aurora** clusters (`aurora-postgresql`, `aurora-mysql`) and **Multi-AZ DB clusters** (`postgres`, `mysql`), with engine-aware branching.

## Features

- Aurora cluster with a configurable map of cluster instances (writer + readers), or Aurora Serverless v2
- Multi-AZ DB cluster (3 managed instances) for `postgres` / `mysql` engines
- AWS-managed master user password via Secrets Manager (default; no password in Terraform state)
- Security group ingress via SG-to-SG references and/or CIDR blocks
- Cluster + instance parameter groups with create/BYO toggles
- Enhanced Monitoring IAM role created automatically when `monitoring_interval > 0`
- Performance Insights, CloudWatch log exports, IAM database authentication
- Precondition checks reject Aurora ↔ Multi-AZ misconfigurations at plan time

## Usage

### Aurora PostgreSQL (provisioned)

```hcl
module "cluster" {
  source  = "terraform.c0x12c.com/c0x12c/rds-cluster/aws"
  version = "0.1.0"

  name            = "rental"
  engine          = "aurora-postgresql"
  engine_version  = "17.9"
  database_name   = "rental"
  master_username = "rentaladmin"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnet_ids

  instance_class = "db.r6g.large"
  instances = {
    main    = { availability_zone = "us-west-2a" }
    replica = { availability_zone = "us-west-2b" }
  }

  db_cluster_parameter_group_family = "aurora-postgresql17"
  db_cluster_parameter_group_parameters = [
    { name = "rds.logical_replication", value = "1", apply_method = "pending-reboot" },
    { name = "wal_sender_timeout", value = "0" },
  ]

  security_group_rules = {
    eks = { source_security_group_id = module.eks.worker_sg_id }
    dms = { source_security_group_id = module.dms.security_group }
  }

  monitoring_interval                   = 60
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  tags = { Environment = "prod" }
}
```

### Aurora Serverless v2

```hcl
module "cluster" {
  source  = "terraform.c0x12c.com/c0x12c/rds-cluster/aws"
  version = "0.1.0"

  name            = "analytics"
  engine          = "aurora-postgresql"
  engine_version  = "17.9"
  master_username = "admin"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnet_ids

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 4
  }

  instances = {
    main = {}
  }

  db_cluster_parameter_group_family = "aurora-postgresql17"
}
```

### Multi-AZ DB cluster (PostgreSQL)

```hcl
module "cluster" {
  source  = "terraform.c0x12c.com/c0x12c/rds-cluster/aws"
  version = "0.1.0"

  name            = "billing"
  engine          = "postgres"
  engine_version  = "18.3"
  database_name   = "billing"
  master_username = "billingadmin"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnet_ids

  # gp3 with custom IOPS on postgres requires allocated_storage >= 400 GB
  # and iops >= 12000.
  db_cluster_instance_class = "db.r6gd.large"
  allocated_storage         = 400
  iops                      = 12000
  storage_type              = "gp3"

  db_cluster_parameter_group_family = "postgres18"

  monitoring_interval          = 60
  performance_insights_enabled = true
}
```

## Operational notes

- **Master password.** Defaults to `manage_master_user_password = true`, which has RDS create and rotate the secret in AWS Secrets Manager. The secret ARN is exposed via `master_user_secret_arn`. No password material is ever stored in Terraform state.
- **`pending-reboot` parameters are silent footguns.** Parameters set with `apply_method = "pending-reboot"` will not take effect until the cluster (or instance) is rebooted. Plan output will show success even though the parameter is dormant.
- **Multi-AZ DB cluster constraints.** Exactly 3 instances (managed by the cluster resource — do **not** add `aws_rds_cluster_instance` blocks). Memory-optimized instance classes only (`db.r6gd.*`, `db.r5d.*`, `db.m6gd.*`). Storage must be `io1`, `io2`, or `gp3`; **`gp3` with custom `iops` requires `allocated_storage >= 400` and `iops >= 12000`**. No Serverless v2, no Backtrack, no Global Cluster. Engine version support is a strict subset of vanilla RDS — query `aws rds describe-orderable-db-instance-options --engine postgres --db-instance-class db.r6gd.large --query 'OrderableDBInstanceOptions[?SupportsClusters==\`true\`].EngineVersion'` to confirm a version is supported before pinning.
- **Enhanced Monitoring.** When `monitoring_interval > 0`, the module creates an IAM role with `AmazonRDSEnhancedMonitoringRole`. Set `create_monitoring_role = false` and provide `monitoring_role_arn` to reuse an existing role.
- **Performance Insights retention.** 7 days is free; 31, 93, 186, 372, and 731 are paid tiers — check pricing before bumping.
- **Deletion protection** defaults to `true`. Flip to `false` and apply before destroying.

## Examples

- [Aurora PostgreSQL](./examples/aurora-postgresql/)
- [Aurora Serverless v2](./examples/aurora-serverless/)
- [Multi-AZ DB cluster (PostgreSQL)](./examples/multi-az-postgres/)

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.39.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_role.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_rds_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_rds_cluster_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.from_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.from_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_id.snapshot_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_iam_policy_document.monitoring_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Allocated storage in GB. Required for Multi-AZ DB cluster, must be null for Aurora. | `number` | `null` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Whether major engine version upgrades are allowed. | `bool` | `false` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether to apply changes immediately, instead of waiting for the next maintenance window. | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Whether minor engine upgrades are applied automatically during the maintenance window. | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to retain automated backups. | `number` | `7` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Whether to copy cluster tags to snapshots. | `bool` | `true` | no |
| <a name="input_create_db_cluster_parameter_group"></a> [create\_db\_cluster\_parameter\_group](#input\_create\_db\_cluster\_parameter\_group) | Whether to create a DB cluster parameter group. Set false to bring your own. | `bool` | `true` | no |
| <a name="input_create_db_parameter_group"></a> [create\_db\_parameter\_group](#input\_create\_db\_parameter\_group) | Whether to create a DB instance parameter group (Aurora only). | `bool` | `true` | no |
| <a name="input_create_db_subnet_group"></a> [create\_db\_subnet\_group](#input\_create\_db\_subnet\_group) | Whether to create a DB subnet group from `subnets`. Set false to bring your own. | `bool` | `true` | no |
| <a name="input_create_monitoring_role"></a> [create\_monitoring\_role](#input\_create\_monitoring\_role) | Whether the module should create the IAM role used for Enhanced Monitoring. Set false and provide monitoring\_role\_arn to bring your own. | `bool` | `true` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the initial database to create. If null, no database is created. | `string` | `null` | no |
| <a name="input_db_cluster_instance_class"></a> [db\_cluster\_instance\_class](#input\_db\_cluster\_instance\_class) | Instance class for Multi-AZ DB cluster (e.g. db.r6gd.large). Required for Multi-AZ DB cluster, must be null for Aurora. | `string` | `null` | no |
| <a name="input_db_cluster_parameter_group_family"></a> [db\_cluster\_parameter\_group\_family](#input\_db\_cluster\_parameter\_group\_family) | Family for the cluster parameter group (e.g. aurora-postgresql16, postgres16). Required when creating. | `string` | `null` | no |
| <a name="input_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#input\_db\_cluster\_parameter\_group\_name) | Name of an existing cluster parameter group to use when create\_db\_cluster\_parameter\_group is false. | `string` | `null` | no |
| <a name="input_db_cluster_parameter_group_parameters"></a> [db\_cluster\_parameter\_group\_parameters](#input\_db\_cluster\_parameter\_group\_parameters) | List of parameters to set on the cluster parameter group. | <pre>list(object({<br/>    name         = string<br/>    value        = string<br/>    apply_method = optional(string, "immediate")<br/>  }))</pre> | `[]` | no |
| <a name="input_db_parameter_group_family"></a> [db\_parameter\_group\_family](#input\_db\_parameter\_group\_family) | Family for the instance parameter group. Defaults to db\_cluster\_parameter\_group\_family. | `string` | `null` | no |
| <a name="input_db_parameter_group_name"></a> [db\_parameter\_group\_name](#input\_db\_parameter\_group\_name) | Name of an existing instance parameter group to use when create\_db\_parameter\_group is false. | `string` | `null` | no |
| <a name="input_db_parameter_group_parameters"></a> [db\_parameter\_group\_parameters](#input\_db\_parameter\_group\_parameters) | List of parameters to set on the instance parameter group. | <pre>list(object({<br/>    name         = string<br/>    value        = string<br/>    apply_method = optional(string, "immediate")<br/>  }))</pre> | `[]` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | Name of an existing DB subnet group to use (when create\_db\_subnet\_group is false), or override name when creating. | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether deletion protection is enabled. Defaults to true; must be flipped to false before a destroy. | `bool` | `true` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | Set of log types to export to CloudWatch Logs. PostgreSQL: postgresql. MySQL: audit, error, general, slowquery. | `list(string)` | `[]` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Database engine. Aurora engines (`aurora-postgresql`, `aurora-mysql`) provision an Aurora cluster with separate cluster instances. Non-Aurora engines (`postgres`, `mysql`) provision a Multi-AZ DB cluster managed by the cluster resource itself. | `string` | n/a | yes |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | Engine mode for Aurora clusters. Ignored for Multi-AZ DB cluster. | `string` | `"provisioned"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The database engine version. | `string` | n/a | yes |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Whether IAM database authentication is enabled. | `bool` | `false` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Default instance class for Aurora cluster instances when not overridden per-instance. | `string` | `"db.r6g.large"` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Map of Aurora cluster instances to create. Key is the suffix appended to the cluster name. Empty for Multi-AZ DB cluster. | <pre>map(object({<br/>    instance_class          = optional(string)<br/>    availability_zone       = optional(string)<br/>    publicly_accessible     = optional(bool)<br/>    promotion_tier          = optional(number)<br/>    db_parameter_group_name = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | Provisioned IOPS for io1/io2 storage on Multi-AZ DB cluster. Optional for gp3 ≥3000. | `number` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN of the KMS key used for storage encryption. If null, the default RDS-managed key is used. | `string` | `null` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Use AWS-managed master user password (stored in Secrets Manager, auto-rotated by RDS). Recommended. | `bool` | `true` | no |
| <a name="input_master_user_secret_kms_key_id"></a> [master\_user\_secret\_kms\_key\_id](#input\_master\_user\_secret\_kms\_key\_id) | KMS key ID used to encrypt the AWS-managed master user secret. Defaults to aws/secretsmanager. | `string` | `null` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Username for the master DB user. | `string` | n/a | yes |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | Interval in seconds for Enhanced Monitoring. 0 disables. Production recommendation: 30 or 60. | `number` | `0` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | ARN of an existing IAM role for Enhanced Monitoring. Used when create\_monitoring\_role is false. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The cluster identifier and the base name used for related resources (subnet group, security group, parameter groups, instances). | `string` | n/a | yes |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Whether Performance Insights are enabled. | `bool` | `false` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | KMS key ID used to encrypt Performance Insights data. | `string` | `null` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Performance Insights retention in days. 7 is free; 31, 93, 186, 372, 731 are paid tiers. | `number` | `7` | no |
| <a name="input_port"></a> [port](#input\_port) | Port the database accepts connections on. Defaults to 5432 (postgres) or 3306 (mysql). | `number` | `null` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | Daily UTC window when automated backups are taken (HH:MM-HH:MM). | `string` | `"03:00-04:00"` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | Weekly UTC window for system maintenance (ddd:HH:MM-ddd:HH:MM). | `string` | `"sun:04:00-sun:05:00"` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Map of ingress rules for the cluster security group. Each value may set source\_security\_group\_id (preferred for VPC services) and/or cidr\_blocks. from\_port/to\_port default to the database port. | <pre>map(object({<br/>    source_security_group_id = optional(string)<br/>    cidr_blocks              = optional(list(string))<br/>    description              = optional(string)<br/>    from_port                = optional(number)<br/>    to_port                  = optional(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_serverlessv2_scaling_configuration"></a> [serverlessv2\_scaling\_configuration](#input\_serverlessv2\_scaling\_configuration) | Aurora Serverless v2 scaling configuration. When set, instance\_class is forced to db.serverless. Aurora engines only. | <pre>object({<br/>    min_capacity = number<br/>    max_capacity = number<br/>  })</pre> | `null` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Whether to skip the final snapshot before destroying the cluster. | `bool` | `false` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Whether the cluster storage is encrypted. | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage type. For Multi-AZ DB cluster: io1, io2, or gp3 (required). For Aurora: usually null (or aurora-iopt1). | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnet IDs for the DB subnet group. Required when create\_db\_subnet\_group is true. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all created resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID in which the cluster will be deployed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The cluster ARN |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The cluster identifier |
| <a name="output_cluster_resource_id"></a> [cluster\_resource\_id](#output\_cluster\_resource\_id) | The immutable resource ID of the cluster (used in IAM ABAC policies) |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | The name of the initial database |
| <a name="output_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#output\_db\_cluster\_parameter\_group\_name) | Name of the cluster parameter group |
| <a name="output_db_parameter_group_name"></a> [db\_parameter\_group\_name](#output\_db\_parameter\_group\_name) | Name of the instance parameter group (Aurora only) |
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | Name of the DB subnet group used by the cluster |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The writer endpoint |
| <a name="output_instances"></a> [instances](#output\_instances) | Map of Aurora cluster instances by key. Empty for Multi-AZ DB cluster. |
| <a name="output_master_user_secret_arn"></a> [master\_user\_secret\_arn](#output\_master\_user\_secret\_arn) | ARN of the AWS-managed master user secret (when manage\_master\_user\_password is true) |
| <a name="output_master_username"></a> [master\_username](#output\_master\_username) | The master username |
| <a name="output_port"></a> [port](#output\_port) | Port the cluster accepts connections on |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | The load-balanced reader endpoint |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the cluster security group |
<!-- END_TF_DOCS -->

## References

- AWS provider docs: [aws_rds_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster)
- Upstream reference: [terraform-aws-modules/terraform-aws-rds-aurora](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora)
