# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0](https://github.com/c0x12c/terraform-modules/compare/terraform-aws-rds-cluster/v0.1.0...terraform-aws-rds-cluster/v0.2.0) (2026-09-05)


### Features

* **rds-cluster:** build the IAM auth connect policy in the module ([#319](https://github.com/c0x12c/terraform-modules/issues/319)) ([6b53cb2](https://github.com/c0x12c/terraform-modules/commit/6b53cb2e058134bb68fb6ae0fb201274a5f090db))

## [0.1.0] - 2026-04-08

### Features

* Initial release of the AWS RDS Cluster module.
* Supports both Aurora clusters (`aurora-postgresql`, `aurora-mysql`) and Multi-AZ DB clusters (`postgres`, `mysql`) via a single API surface with engine-aware branching.
* Aurora topology configured via an `instances` map (per-instance overrides for AZ, instance class, parameter group, promotion tier).
* Aurora Serverless v2 supported via `serverlessv2_scaling_configuration`.
* Multi-AZ DB cluster supported via `db_cluster_instance_class`, `allocated_storage`, `iops`, `storage_type` (3 instances are managed by the cluster resource).
* Master password managed by RDS / Secrets Manager (`manage_master_user_password`, default true) — no password material in Terraform state.
* Security group ingress configured via `security_group_rules` map supporting both source SG references (preferred) and CIDR blocks.
* Cluster + instance parameter groups with create/BYO toggles and explicit family.
* Enhanced Monitoring IAM role created automatically when `monitoring_interval > 0`.
* Outputs: cluster id/arn/resource id, writer/reader endpoints, port, master user secret ARN, security group id, parameter group names, instances map.
* Precondition validations to reject Aurora ↔ Multi-AZ misconfigurations early.
