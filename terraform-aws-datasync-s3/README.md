# AWS DataSync S3 module

Terraform module which copies one S3 bucket to another with AWS DataSync, including the IAM role, both locations, and the transfer task.

## Features

- DataSync task between two S3 locations, on-demand or on a schedule
- IAM role for DataSync with read on the source bucket and write on the destination, plus optional KMS grants for SSE-KMS buckets
- Cross-account sources: the task runs in the destination account and only needs a matching source bucket policy
- CloudWatch log group for transfer errors and task reports written to the destination bucket
- `create = false` turns the whole module into a no-op, so an idle transfer can stay in code

## Usage

```hcl
module "s3_datasync" {
  source  = "terraform.c0x12c.com/c0x12c/datasync-s3/aws"
  version = "~> 0.1"

  name = "example-transfer"

  source_bucket_arn      = "arn:aws:s3:::example-source-bucket"
  destination_bucket_arn = module.destination_bucket.s3_bucket_arn

  schedule_expression = "cron(0 * * * ? *)"

  tags = { Environment = "staging" }
}
```

Start an on-demand run once applied:

```bash
aws datasync start-task-execution --task-arn "$(terraform output -raw task_arn)"
```

## Operational notes

- **Cross-account source.** The task runs in the destination account, so the source
  account must add a bucket policy granting `iam_role_arn` `s3:ListBucket` /
  `s3:GetBucketLocation` on the bucket and `s3:GetObject*` on its objects. Apply this
  module first, then the bucket policy, then start the task.
- **Deletes are not propagated.** `preserve_deleted_files = PRESERVE` keeps destination
  objects that disappear from the source, so a mid-migration cleanup on the source cannot
  wipe the destination. Override it through `task_options` for a true mirror.
- **Do not run alongside S3 Replication** on the same bucket pair — the two fight over the
  same objects. Keep `create = false` while the transfer is idle.
- **Logging.** `BASIC` is the finest CloudWatch level DataSync offers (transfer errors
  only); per-object detail comes from the task report on the destination bucket under
  `task_report_subdirectory`. CloudWatch Logs caps resource policies at 10 per region and
  the one created here covers every task in the account, so set
  `create_cloudwatch_log_resource_policy = false` on additional instances.
- **Encrypted buckets.** Pass the bucket key ARNs in `kms_key_arns`, otherwise the
  transfer fails on `AccessDenied` at the first object.

## Examples

See [`examples/complete`](examples/complete) for a runnable example.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.63.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_datasync_location_s3.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_s3) | resource |
| [aws_datasync_location_s3.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_s3) | resource |
| [aws_datasync_task.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | KMS key ARN encrypting the log group. Null uses the CloudWatch Logs default key. | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Name of the log group. Defaults to `/aws/datasync/<name>`. | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Retention of the DataSync log group. | `number` | `14` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether to create the DataSync task and its supporting resources. | `bool` | `true` | no |
| <a name="input_create_cloudwatch_log_resource_policy"></a> [create\_cloudwatch\_log\_resource\_policy](#input\_create\_cloudwatch\_log\_resource\_policy) | Whether to create the log resource policy letting DataSync write to the log group. One policy covers every task in the region, so set false on additional instances. | `bool` | `true` | no |
| <a name="input_destination_bucket_arn"></a> [destination\_bucket\_arn](#input\_destination\_bucket\_arn) | ARN of the S3 bucket to write to. Must be in the account the task runs in. | `string` | n/a | yes |
| <a name="input_destination_storage_class"></a> [destination\_storage\_class](#input\_destination\_storage\_class) | Storage class objects are written with. Null uses the DataSync default (STANDARD). | `string` | `null` | no |
| <a name="input_destination_subdirectory"></a> [destination\_subdirectory](#input\_destination\_subdirectory) | Prefix on the destination bucket to write under. `/` is the whole bucket. | `string` | `"/"` | no |
| <a name="input_enable_cloudwatch_logging"></a> [enable\_cloudwatch\_logging](#input\_enable\_cloudwatch\_logging) | Whether to create a CloudWatch log group for the task. False turns task logging off entirely. | `bool` | `true` | no |
| <a name="input_enable_task_report"></a> [enable\_task\_report](#input\_enable\_task\_report) | Whether the task writes reports to the destination bucket. | `bool` | `true` | no |
| <a name="input_excluded_patterns"></a> [excluded\_patterns](#input\_excluded\_patterns) | Simple patterns excluded from the transfer, e.g. `["/tmp/*"]`. | `list(string)` | `[]` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role DataSync assumes. Defaults to `<name>-datasync`. | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | Permissions boundary ARN applied to the IAM role. | `string` | `null` | no |
| <a name="input_included_patterns"></a> [included\_patterns](#input\_included\_patterns) | Simple patterns to limit the transfer to, e.g. `["/uploads/*"]`. | `list(string)` | `[]` | no |
| <a name="input_kms_key_arns"></a> [kms\_key\_arns](#input\_kms\_key\_arns) | KMS key ARNs the task may use. Required when either bucket is SSE-KMS encrypted. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the DataSync task, and base name for the IAM role, locations, and log group. | `string` | n/a | yes |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Cron or rate expression that runs the task on a schedule, e.g. `cron(0 * * * ? *)`. Null leaves it on-demand. | `string` | `null` | no |
| <a name="input_source_bucket_arn"></a> [source\_bucket\_arn](#input\_source\_bucket\_arn) | ARN of the S3 bucket to read from. May live in another account (see README). | `string` | n/a | yes |
| <a name="input_source_storage_class"></a> [source\_storage\_class](#input\_source\_storage\_class) | Storage class of the source location. Null uses the DataSync default (STANDARD). | `string` | `null` | no |
| <a name="input_source_subdirectory"></a> [source\_subdirectory](#input\_source\_subdirectory) | Prefix on the source bucket to transfer. `/` is the whole bucket. | `string` | `"/"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all created resources. | `map(string)` | `{}` | no |
| <a name="input_task_options"></a> [task\_options](#input\_task\_options) | DataSync task options. Defaults suit an S3-to-S3 copy: transfer only changed objects and never delete on the destination. | <pre>object({<br/>    verify_mode            = optional(string, "ONLY_FILES_TRANSFERRED")<br/>    overwrite_mode         = optional(string, "ALWAYS")<br/>    preserve_deleted_files = optional(string, "PRESERVE")<br/>    preserve_devices       = optional(string, "NONE")<br/>    posix_permissions      = optional(string, "NONE")<br/>    uid                    = optional(string, "NONE")<br/>    gid                    = optional(string, "NONE")<br/>    atime                  = optional(string, "BEST_EFFORT")<br/>    mtime                  = optional(string, "PRESERVE")<br/>    transfer_mode          = optional(string, "CHANGED")<br/>    object_tags            = optional(string, "PRESERVE")<br/>    log_level              = optional(string, "BASIC")<br/>  })</pre> | `{}` | no |
| <a name="input_task_report_level"></a> [task\_report\_level](#input\_task\_report\_level) | Detail of the task report: ERRORS\_ONLY or SUCCESSES\_AND\_ERRORS. | `string` | `"ERRORS_ONLY"` | no |
| <a name="input_task_report_output_type"></a> [task\_report\_output\_type](#input\_task\_report\_output\_type) | Task report output type: STANDARD or SUMMARY\_ONLY. | `string` | `"STANDARD"` | no |
| <a name="input_task_report_subdirectory"></a> [task\_report\_subdirectory](#input\_task\_report\_subdirectory) | Prefix on the destination bucket the task reports are written to. | `string` | `"/datasync-reports"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch log group receiving transfer errors. |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of the CloudWatch log group receiving transfer errors. |
| <a name="output_destination_bucket_name"></a> [destination\_bucket\_name](#output\_destination\_bucket\_name) | Name of the destination bucket. |
| <a name="output_destination_location_arn"></a> [destination\_location\_arn](#output\_destination\_location\_arn) | ARN of the destination S3 location. |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the role DataSync assumes. Grant it read access in a cross-account source bucket policy. |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the role DataSync assumes. |
| <a name="output_source_bucket_name"></a> [source\_bucket\_name](#output\_source\_bucket\_name) | Name of the source bucket. |
| <a name="output_source_location_arn"></a> [source\_location\_arn](#output\_source\_location\_arn) | ARN of the source S3 location. |
| <a name="output_task_arn"></a> [task\_arn](#output\_task\_arn) | ARN of the DataSync task. Run it with `aws datasync start-task-execution --task-arn`. |
| <a name="output_task_name"></a> [task\_name](#output\_task\_name) | Name of the DataSync task. |
| <a name="output_task_report_s3_uri"></a> [task\_report\_s3\_uri](#output\_task\_report\_s3\_uri) | s3:// prefix the task reports are written to. |
<!-- END_TF_DOCS -->
