# AWS RDS Terraform module

Terraform module which creates RDS resources on AWS.

This module will create the following components:

- A main RDS instance, we can also specify whether create RDS replicas for the master one
- The parameter group for RDS can be configured and viewed in the `parameter_group.tf` file

## Usage

### Create RDS PostgreSQL

```hcl
module "instance" {
  source  = "terraform.c0x12c.com/c0x12c/rds/aws"
  version = "1.0.0"

  db_name                             = "example_rds"
  db_username                         = "exampleuser"
  engine_version                      = "18.4"
  instance_class                      = "db.t4g.micro"
  disk_size                           = 20
  iam_database_authentication_enabled = false
  replica_count                       = 0
  vpc_id                              = "vpc-123456789"
  subnet_ids                          = []
  storage_type                        = "gp3"
}
```

Set `engine_version` explicitly. The module's default tracks a currently-orderable version,
but AWS retires minor versions on its own schedule, and a retired one fails at
`CreateDBInstance` rather than at plan - so a default that was fine when it was written can
break greenfield creates later with no change on your side. Pinning the value in your own
config is the only way to control when the engine version moves.
`db.t4g.micro` on `gp3` is the cheapest orderable combination for a scratch instance.

## Upgrading to 1.0.0

Two defaults changed. Together they make a major engine upgrade something you ask for rather
than something you receive. Read this before taking 1.0.0 on an existing instance.

**`allow_major_version_upgrade` now defaults to `false`** (was `true`). This is the safety
net: if you never set `engine_version`, the next `apply` after this upgrade **fails** rather
than performing an in-place Postgres 16 to 18 upgrade. A major upgrade takes the instance
offline for the duration and is not reversible without a restore - failing the apply is the
correct outcome for something nobody asked for. The old `true` also inverted AWS's own
default, and contradicted `auto_minor_version_upgrade` in this same module, which has always
defaulted to `false`.

**`engine_version` now defaults to `18.4`** (was the retired `16.4`, which failed at
`CreateDBInstance` for every new instance).

### If you set `engine_version` explicitly

Nothing to do. Both changes are invisible to you.

### If you rely on the default

Pin the version your instance is actually running before taking 1.0.0:

```bash
aws rds describe-db-instances \
  --db-instance-identifier <your-instance> \
  --query 'DBInstances[0].EngineVersion' --output text
```

```hcl
module "instance" {
  source  = "terraform.c0x12c.com/c0x12c/rds/aws"
  version = "1.0.0"

  engine_version = "16.10"  # whatever the command above returned
  # ...
}
```

Then `plan` and confirm no engine change is proposed. If you skip this step the apply fails
with a major-version-upgrade error rather than upgrading you - noisy, but safe and
recoverable by pinning.

### Performing a major upgrade on purpose

Raise `engine_version` and set the flag in the same apply, then remove the flag afterwards so
the next unrelated change cannot ride on it:

```hcl
engine_version              = "18.4"
allow_major_version_upgrade = true
```

Take a snapshot first. The upgrade is offline and not reversible without a restore.

New instances need no action - 18.4 is a good default for a fresh database.

## Examples

- [Example](./examples/complete/)

## Master password: which mode to use

The master credential can be owned by Terraform or by AWS, and the two are mutually exclusive. Pick a row, then see the section below for the details.

| You want | Set | Who rotates |
|---|---|---|
| A generated password, never rotated | nothing (default) | nobody |
| A generated password, rotated when you say | `db_password_rotation_id` | you, by changing the value |
| A generated password, rotated on an interval | `db_password_rotation_id` from a `time_rotating` | your pipeline, on each run |
| AWS to own and rotate the credential | `manage_master_user_password` | RDS, every 7 days |
| AWS to rotate on your cadence | `+ master_user_secret_rotation_days` | RDS, every N days |
| AWS to rotate in a controlled window | `+ ..._rotation_schedule` / `..._duration` | RDS, on your schedule |
| A read replica | anything except `manage_master_user_password` | see Constraints |

### Terraform-owned password

Default. The module generates the password and holds it in state; `db_password` returns it.

```hcl
module "db" {
  source = "terraform.c0x12c.com/c0x12c/rds/aws"

  db_name     = "example"
  db_username = "example"
  # ...
}
```

Rotate it on demand by changing `db_password_rotation_id` to any new value. A date reads well:

```hcl
db_password_rotation_id = "2026-08"
```

There is no "stop rotating" transition: **any** change to the value rotates, including
clearing it back to `null` after it has been set. To stop rotating, leave the last value in
place rather than removing the line. Never having set it at all is the only state that never
rotates.

For an interval rather than a manual bump, drive it from `time_rotating` in the calling configuration. Deliberately not built into the module - it would add a provider dependency for every consumer, including those who never rotate:

```hcl
resource "time_rotating" "db_password" {
  rotation_days = 30
}

module "db" {
  db_password_rotation_id = time_rotating.db_password.id
  # ...
}
```

This fires on the run *after* the interval elapses, not on the day itself, so it needs runs to happen. Somewhere applied only on demand will drift.

### AWS-owned password

RDS generates the credential, stores it in Secrets Manager, and rotates it natively without a run. `db_password` is `null` unless you opt in with `expose_managed_master_password`; use `db_password_secret_arn` to find the secret.

Enabling this on an existing instance is a migration, not a toggle - see the two-step below.

```hcl
manage_master_user_password = true
```

Every 30 days instead of AWS's 7:

```hcl
manage_master_user_password      = true
master_user_secret_rotation_days = 30
```

Inside a controlled window - 06:00 UTC on the 1st of the month, finishing within two hours. Use this when a credential change has to miss a traffic peak or a batch job:

```hcl
manage_master_user_password          = true
master_user_secret_rotation_schedule = "cron(0 6 1 * ? *)"
master_user_secret_rotation_duration = "2h"
```

### With a read replica

`manage_master_user_password` is rejected here, so stay on the Terraform-owned password and rotate it with `db_password_rotation_id`:

```hcl
replica_count           = 1
db_password_rotation_id = "2026-08"
```

## Master password rotation

Set `manage_master_user_password = true` to hand the master credential to AWS Secrets Manager so RDS rotates it natively on its own schedule without requiring `terraform apply`.

Enabling AWS-managed rotation on an existing instance is a migration, not a simple toggle. AWS creates a new master password immediately, so anything still authenticating with the old static password breaks at that moment.

Terraform only re-reads the managed secret during `apply`, so any downstream consumer that writes `db_password` into a Kubernetes Secret keeps the value from the last apply and goes stale between AWS rotations. That exposure mode is only safe for break-glass access patterns such as RDS IAM-authenticated applications. Otherwise, consume the secret ARN with External Secrets Operator or an equivalent runtime sync.

When `manage_master_user_password = true` and `expose_managed_master_password = false` (the default), the `db_password` output is intentionally `null`. Use `db_password_secret_arn` to discover the AWS-managed secret instead.

### New instances are fine; enabling on an existing one takes two steps

On a **new** instance, set `manage_master_user_password` and `expose_managed_master_password` together and apply once. The instance and its managed secret are created during that apply, so the secret is readable by the time the module reads it and `db_password` resolves normally. Verified end to end against a real instance.

On an **existing** instance, enable managed credentials out of band first:

```
aws rds modify-db-instance --db-instance-identifier <id> --manage-master-user-password --apply-immediately
```

Then turn the flags on. The difference is that Terraform refreshes the existing instance before planning and sees no managed secret, so the ARN reads as `null` rather than as not-yet-known - and a `null` `secret_id` is a hard plan error that aborts the plan for every other resource in the root, not just this one. Enabling out of band first means the ARN already exists when Terraform looks.

### Constraints

`manage_master_user_password` cannot be combined with `replica_count > 0`. RDS does not support creating a read replica from a source that manages its master credentials in Secrets Manager, and the module rejects the combination at plan time rather than letting it fail during apply.

`master_user_secret_kms_key_id` is effectively immutable once RDS is managing the credential - AWS rejects a KMS key change after the fact, and the module cannot detect that at plan time. Choose the key before enabling.

### Turning it back off

Setting `manage_master_user_password` back to `false` is a second credential rotation, not a restore. Terraform never knew the AWS-managed value, so it generates a fresh `random_password` and pushes that as the new master password. Plan for the same auth-break window as the original migration.

### Operability

AWS rotates the managed secret on its own schedule, every seven days by default. The module can manage an `aws_secretsmanager_secret_rotation` against that secret so the cadence is codified rather than set by hand. Three inputs, all optional:

| Input | Purpose |
|---|---|
| `master_user_secret_rotation_days` | Rotate every N days, counted from the last rotation. |
| `master_user_secret_rotation_schedule` | A `cron()` or `rate()` expression, in UTC, when rotation must land at a controlled time rather than N days after the last one. |
| `master_user_secret_rotation_duration` | Length of the rotation window, e.g. `"3h"`. Rotation happens at some point inside it. |

`master_user_secret_rotation_days` and `master_user_secret_rotation_schedule` are mutually exclusive - Secrets Manager accepts `AutomaticallyAfterDays` or `ScheduleExpression`, never both - and the module rejects the combination at plan time.

Pick the interval form when you only care how often, and the schedule form when you care when. Rotation briefly changes the master credential, so a window matters if that has to avoid a traffic peak or a batch job:

```hcl
# every 30 days, whenever AWS chooses within that day
master_user_secret_rotation_days = 30

# 06:00 UTC on the 1st of each month, finishing within two hours
master_user_secret_rotation_schedule = "cron(0 6 1 * ? *)"
master_user_secret_rotation_duration = "2h"
```

The window is anchored by the schedule and must not run into the next UTC day or the next rotation window. Without a duration, an hourly schedule closes the window after an hour and a daily one closes it at the end of the UTC day.

Leave all three `null` (the default) to keep RDS's own seven-day cadence. The null default matters on adoption: because seven days is already tighter than most explicit choices, a built-in default of, say, thirty would *loosen* rotation on every managed instance the moment this module version is bumped. Opting in keeps that a deliberate decision.

The module always sends `rotate_immediately = false`. The provider defaults it to `true`, so managing this without pinning it would rotate the master password on the apply that adopts the variable - an unannounced credential change across every managed instance at once. Rotate out of band if you want one immediately.

No rotation Lambda is involved: `rotation_lambda_arn` is optional and the provider only sends it when set (verified in 5.100.0 and on the current 6.x line, both inside this module's `>= 5.75` constraint).

### Knowing when rotation breaks

Rotation failing is silent. The secret stops rotating - typically after an IAM or KMS permission change moves its status to `impaired` - nothing fails at the time, and the first symptom is an authentication error much later with nothing pointing back to the cause.

Set `master_user_secret_rotation_failure_sns_topic_arn` and the module wires an EventBridge rule for `RotationFailed` and `RotationAbandoned` on this secret, targeting your topic:

```hcl
master_user_secret_rotation_days                  = 30
master_user_secret_rotation_failure_sns_topic_arn = aws_sns_topic.alerts.arn
```

The topic's own resource policy must allow `events.amazonaws.com` to publish. That belongs with the topic, not here, so a topic without it drops the notifications silently.

### Verified behaviour

Checked against a real RDS-owned secret rather than inferred:

- Rotation is performed by RDS itself. `describe-secret` reports `RotationEnabled: true` with the configured interval and **no** `RotationLambdaARN`.
- Rotation events arrive as CloudTrail `AwsServiceEvent` (`detail-type: AWS Service Event via CloudTrail`) and carry the secret ARN at `additionalEventData.SecretId`, which is what the rule above filters on.
- RDS does **not** re-assert its own cadence after a rotation. Following a forced rotation the configured interval was unchanged, `NextRotationDate` was recalculated from it, and `terraform plan` reported no changes - so this resource does not produce perpetual drift.
- Creating a new instance with `manage_master_user_password` and `expose_managed_master_password` set together works in a single apply; `db_password` resolves.

One permission caveat: the module's rotation call needs `secretsmanager:RotateSecret`. A least-privilege CI role may not have it yet.

Enabling this requires the applying principal to hold `secretsmanager:CreateSecret`, `secretsmanager:TagResource`, and `kms:DescribeKey`, plus `kms:Decrypt`, `kms:GenerateDataKey`, and `kms:CreateGrant` when using a customer-managed key, and `secretsmanager:RotateSecret` when a rotation schedule is set.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.58.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_main_db_instance"></a> [main\_db\_instance](#module\_main\_db\_instance) | ./db_instance | n/a |
| <a name="module_replica_db_instance"></a> [replica\_db\_instance](#module\_replica\_db\_instance) | ./db_instance | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.master_secret_rotation_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.master_secret_rotation_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_db_parameter_group.parameter_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_rotation.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_secretsmanager_random_password.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_random_password) | data source |
| [aws_secretsmanager_secret_version.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_postgres_parameters"></a> [additional\_postgres\_parameters](#input\_additional\_postgres\_parameters) | Additional postgres parameters to add to parameter groups. | <pre>map(object({<br/>    value        = any<br/>    apply_method = string<br/>  }))</pre> | `null` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Whether a major engine version upgrade is allowed. Defaults to false: with it off, raising engine\_version across a major fails the apply instead of silently performing an offline, non-reversible in-place upgrade. Turn it on deliberately for the apply that performs the upgrade. | `bool` | `false` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply any changes to this database immediately. | `bool` | `true` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Indicates whether minor engine upgrades will be applied automatically to the DB instance during the maintenance window. | `bool` | `false` | no |
| <a name="input_backup_retention_day"></a> [backup\_retention\_day](#input\_backup\_retention\_day) | The number of days to retain database backups (default is 7 days). | `number` | `7` | no |
| <a name="input_cloudwatch_exported_log_types"></a> [cloudwatch\_exported\_log\_types](#input\_cloudwatch\_exported\_log\_types) | List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine). MySQL and MariaDB: audit, error, general, slowquery. PostgreSQL: postgresql, upgrade. MSSQL: agent , error. Oracle: alert, audit, listener, trace. | `list(string)` | `null` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Indicates whether all instance tags should be copied to snapshots. | `bool` | `true` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The name of the database. | `string` | n/a | yes |
| <a name="input_db_password_rotation_id"></a> [db\_password\_rotation\_id](#input\_db\_password\_rotation\_id) | Change this to rotate the generated master password. ANY change to this value regenerates the password on the next apply - including clearing it back to null once it has been set, which rotates rather than disabling rotation. Leaving it at the default null forever never rotates. Ignored when use\_secret\_manager or manage\_master\_user\_password is set. String rather than number so callers can use a date, e.g. "2026-08". | `string` | `null` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | The subnet group name for instance. | `string` | `null` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | The master username for the database. | `string` | n/a | yes |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | The disk size of the database instance, in gigabytes. | `number` | `20` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The database engine to be used (e.g., postgres). | `string` | `"postgres"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The version of the database engine to use (default is 18.4). | `string` | `"18.4"` | no |
| <a name="input_expose_managed_master_password"></a> [expose\_managed\_master\_password](#input\_expose\_managed\_master\_password) | Opt in to resolving the managed secret's plaintext back into the db\_password output. Disabled by default to keep the managed password out of Terraform state. Enable managed credentials on the instance before turning this on: on the apply that first enables them the secret does not exist yet, so db\_password resolves to null for that run. | `bool` | `false` | no |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Enable database authentication using AWS IAM. | `bool` | `false` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance class for the database. | `string` | `"db.m5.large"` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Let AWS own and natively rotate the master password in Secrets Manager. Mutually exclusive with a Terraform-generated password. | `bool` | `false` | no |
| <a name="input_master_user_secret_kms_key_id"></a> [master\_user\_secret\_kms\_key\_id](#input\_master\_user\_secret\_kms\_key\_id) | KMS key for the managed secret; null uses the AWS-managed key. | `string` | `null` | no |
| <a name="input_master_user_secret_rotation_days"></a> [master\_user\_secret\_rotation\_days](#input\_master\_user\_secret\_rotation\_days) | Rotate the managed master secret every N days. Null (the default) leaves RDS's own cadence alone, which is every 7 days. Mutually exclusive with master\_user\_secret\_rotation\_schedule. Only meaningful with manage\_master\_user\_password. | `number` | `null` | no |
| <a name="input_master_user_secret_rotation_duration"></a> [master\_user\_secret\_rotation\_duration](#input\_master\_user\_secret\_rotation\_duration) | Length of the rotation window in hours, e.g. "3h" - rotation happens at some point inside it. Optional: without it a schedule in hours closes the window after an hour, and a schedule in days closes it at the end of the UTC day. The window must not run into the next UTC day or the next rotation window. | `string` | `null` | no |
| <a name="input_master_user_secret_rotation_failure_sns_topic_arn"></a> [master\_user\_secret\_rotation\_failure\_sns\_topic\_arn](#input\_master\_user\_secret\_rotation\_failure\_sns\_topic\_arn) | SNS topic to notify when rotation of the managed master secret fails or is abandoned. Null disables the notification. Rotation failing is otherwise silent - the secret stops rotating and nothing surfaces until the next authentication after a failed rotation. | `string` | `null` | no |
| <a name="input_master_user_secret_rotation_schedule"></a> [master\_user\_secret\_rotation\_schedule](#input\_master\_user\_secret\_rotation\_schedule) | A cron() or rate() expression placing rotation of the managed master secret on a specific schedule, in UTC - e.g. cron(0 6 1 * ? *) for 06:00 on the 1st, or rate(10 days). Use instead of master\_user\_secret\_rotation\_days when the rotation needs to land at a controlled time rather than N days after the last one. | `string` | `null` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | The upper limit (in GB) to which Amazon RDS can automatically scale the storage of the DB instance. | `number` | `1000` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval in seconds between points when Enhanced Monitoring metrics are collected for the DB instance. | `number` | `0` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Indicates whether the database instance should be deployed across multiple availability zones. | `bool` | `false` | no |
| <a name="input_password_length"></a> [password\_length](#input\_password\_length) | Database password length. | `number` | `24` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Specifies whether Performance Insights are enabled for the DB instance. | `bool` | `false` | no |
| <a name="input_port"></a> [port](#input\_port) | The port of the database. | `number` | `5432` | no |
| <a name="input_primary_deletion_protection"></a> [primary\_deletion\_protection](#input\_primary\_deletion\_protection) | If the DB primary instance should have deletion protection enabled. The instance can't be deleted when this value is set to true. | `bool` | `true` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Indicates whether the database can be publicly available. | `bool` | `false` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | The number of read replicas for the database. | `number` | n/a | yes |
| <a name="input_replica_deletion_protection"></a> [replica\_deletion\_protection](#input\_replica\_deletion\_protection) | If the DB replicas should have deletion protection enabled. The instances can't be deleted when this value is set to true. | `bool` | `true` | no |
| <a name="input_secret_manager_db_password_name"></a> [secret\_manager\_db\_password\_name](#input\_secret\_manager\_db\_password\_name) | Secret name created in AWS Secret Manager. | `string` | `"POSTGRESQL_PASSWORD"` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Defines whether a final DB snapshot is created before the DB instance is deleted. | `bool` | `true` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Whether the DB instance is encrypted. | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | The storage type of the RDS instance (standard, gp2, or gp3). | `string` | `"gp3"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs for the DB subnet group. | `list(string)` | n/a | yes |
| <a name="input_supported_engine_version"></a> [supported\_engine\_version](#input\_supported\_engine\_version) | A list of supported engine versions for the Parameter Groups, supporting Blue-Green deployment. | `list(string)` | `[]` | no |
| <a name="input_use_secret_manager"></a> [use\_secret\_manager](#input\_use\_secret\_manager) | Whether to use AWS Secret Manager storing Database password. | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which the RDS instance will be launched. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | The name of the database |
| <a name="output_db_password"></a> [db\_password](#output\_db\_password) | The master password for the database |
| <a name="output_db_password_secret_arn"></a> [db\_password\_secret\_arn](#output\_db\_password\_secret\_arn) | The ARN of the AWS Secrets Manager secret storing the database password |
| <a name="output_db_port"></a> [db\_port](#output\_db\_port) | The port number the database instance is listening on |
| <a name="output_db_username"></a> [db\_username](#output\_db\_username) | The master username for the database |
| <a name="output_main_address"></a> [main\_address](#output\_main\_address) | The DNS address of the main RDS instance |
| <a name="output_replica_address"></a> [replica\_address](#output\_replica\_address) | The DNS address of the first replica instance, or main instance if no replicas exist |
<!-- END_TF_DOCS -->
