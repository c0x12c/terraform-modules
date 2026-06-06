# Changelog

All notable changes to this project will be documented in this file.

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
