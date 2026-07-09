# AWS DataSync Terraform module

Terraform module which provisions an AWS DataSync task and its source and destination locations.

## Features

- Creates a DataSync task wiring a source location to a destination location
- Creates the location for either side from typed inputs: an S3 location or an
  S3-compatible object-storage location (Google Cloud Storage, MinIO, …)
- Accepts a bring-your-own location ARN for any type the module does not create
  (EFS, NFS, SMB, FSx, HDFS)
- Creates a least-privilege DataSync IAM access role for an S3 location when one
  is not supplied
- Optional schedule, include/exclude filters, and task options passthrough
- Optional CloudWatch log group with the resource policy DataSync needs to write

## Usage

```hcl
module "datasync" {
  source  = "terraform.c0x12c.com/c0x12c/datasync/aws"
  version = "~> 0.1"

  name = "gcs-to-s3"

  source_object_storage = {
    server_hostname = "storage.googleapis.com"
    bucket_name     = "my-source-bucket"
    agent_arns      = [aws_datasync_agent.this.arn]
    access_key      = var.gcs_hmac_access_key
    secret_key      = var.gcs_hmac_secret_key
  }

  destination_s3 = {
    s3_bucket_arn = aws_s3_bucket.destination.arn
    subdirectory  = "/incoming"
  }

  schedule_expression         = "rate(1 day)"
  create_cloudwatch_log_group = true

  tags = {
    Environment = "dev"
  }
}
```

## Operational notes

- **One location per side.** Set exactly one of `source_s3`,
  `source_object_storage`, or `source_location_arn` (and likewise for the
  destination). Setting zero or more than one fails a precondition.
- **Object-storage agents.** `agent_arns` is required for an object-storage
  location; the module does not create DataSync agents. Deploy the agent(s)
  separately and pass their ARNs.
- **S3 access role.** DataSync assumes an IAM role to read/write an S3 bucket.
  Pass `bucket_access_role_arn` to reuse an existing role, or leave it null and
  the module creates one scoped to that bucket. Created role ARNs are exposed via
  the `s3_access_role_arns` output.
- **CloudWatch logging.** With `create_cloudwatch_log_group = true` the module
  creates `/aws/datasync/<name>` and a log-resource policy allowing
  `datasync.amazonaws.com` to write. Alternatively pass `cloudwatch_log_group_arn`
  to bring your own; set neither to disable task logging.

## Examples

See [`examples/complete`](examples/complete) for a runnable example.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_datasync_location_object_storage.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_object_storage) | resource |
| [aws_datasync_location_object_storage.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_object_storage) | resource |
| [aws_datasync_location_s3.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_s3) | resource |
| [aws_datasync_location_s3.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_s3) | resource |
| [aws_datasync_task.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task) | resource |
| [aws_iam_role.s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#input\_cloudwatch\_log\_group\_arn) | ARN of an existing CloudWatch log group to wire to the task. Ignored when create\_cloudwatch\_log\_group is true. | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | ARN of the KMS key used to encrypt the created log group. If null, logs are encrypted with the CloudWatch-managed key. | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Name of the log group to create. Defaults to /aws/datasync/<name>. | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Retention in days for the created log group. | `number` | `14` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Whether to create a CloudWatch log group for the task and a resource policy allowing DataSync to write to it. Mutually exclusive with cloudwatch\_log\_group\_arn. | `bool` | `false` | no |
| <a name="input_destination_location_arn"></a> [destination\_location\_arn](#input\_destination\_location\_arn) | Bring-your-own ARN of an existing DataSync location to use as the destination (for location types the module does not create). | `string` | `null` | no |
| <a name="input_destination_object_storage"></a> [destination\_object\_storage](#input\_destination\_object\_storage) | Create an S3-compatible object-storage location (e.g. Google Cloud Storage, MinIO) as the destination. agent\_arns is required; the module does not create DataSync agents. | <pre>object({<br/>    server_hostname = string<br/>    bucket_name     = string<br/>    agent_arns      = list(string)<br/>    subdirectory    = optional(string)<br/>    access_key      = optional(string)<br/>    secret_key      = optional(string)<br/>    server_protocol = optional(string)<br/>    server_port     = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_destination_s3"></a> [destination\_s3](#input\_destination\_s3) | Create an S3 location as the destination. When bucket\_access\_role\_arn is null, the module creates a least-privilege DataSync access role scoped to the bucket. | <pre>object({<br/>    s3_bucket_arn          = string<br/>    subdirectory           = optional(string, "/")<br/>    bucket_access_role_arn = optional(string)<br/>    s3_storage_class       = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_exclude_patterns"></a> [exclude\_patterns](#input\_exclude\_patterns) | List of SIMPLE\_PATTERN filters excluding files from the transfer. Joined with '\|' into the task excludes block. Empty means no exclude filter. | `list(string)` | `[]` | no |
| <a name="input_include_patterns"></a> [include\_patterns](#input\_include\_patterns) | List of SIMPLE\_PATTERN filters limiting which files are transferred. Joined with '\|' into the task includes block. Empty means no include filter. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the DataSync task and the base name for related resources (locations, IAM role, log group). | `string` | n/a | yes |
| <a name="input_options"></a> [options](#input\_options) | DataSync task options. When null the options block is omitted and AWS defaults apply. Each attribute maps to the aws\_datasync\_task options block. | <pre>object({<br/>    atime                          = optional(string)<br/>    bytes_per_second               = optional(number)<br/>    gid                            = optional(string)<br/>    log_level                      = optional(string)<br/>    mtime                          = optional(string)<br/>    object_tags                    = optional(string)<br/>    overwrite_mode                 = optional(string)<br/>    posix_permissions              = optional(string)<br/>    preserve_deleted_files         = optional(string)<br/>    preserve_devices               = optional(string)<br/>    security_descriptor_copy_flags = optional(string)<br/>    task_queueing                  = optional(string)<br/>    transfer_mode                  = optional(string)<br/>    uid                            = optional(string)<br/>    verify_mode                    = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Schedule for the task as a rate() or cron() expression. When null the task runs only on manual start. | `string` | `null` | no |
| <a name="input_source_location_arn"></a> [source\_location\_arn](#input\_source\_location\_arn) | Bring-your-own ARN of an existing DataSync location to use as the source (for location types the module does not create). | `string` | `null` | no |
| <a name="input_source_object_storage"></a> [source\_object\_storage](#input\_source\_object\_storage) | Create an S3-compatible object-storage location (e.g. Google Cloud Storage, MinIO) as the source. agent\_arns is required; the module does not create DataSync agents. | <pre>object({<br/>    server_hostname = string<br/>    bucket_name     = string<br/>    agent_arns      = list(string)<br/>    subdirectory    = optional(string)<br/>    access_key      = optional(string)<br/>    secret_key      = optional(string)<br/>    server_protocol = optional(string)<br/>    server_port     = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_source_s3"></a> [source\_s3](#input\_source\_s3) | Create an S3 location as the source. When bucket\_access\_role\_arn is null, the module creates a least-privilege DataSync access role scoped to the bucket. | <pre>object({<br/>    s3_bucket_arn          = string<br/>    subdirectory           = optional(string, "/")<br/>    bucket_access_role_arn = optional(string)<br/>    s3_storage_class       = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all taggable resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch log group wired to the task (null when logging is off) |
| <a name="output_destination_location_arn"></a> [destination\_location\_arn](#output\_destination\_location\_arn) | Effective ARN of the destination location |
| <a name="output_s3_access_role_arns"></a> [s3\_access\_role\_arns](#output\_s3\_access\_role\_arns) | ARNs of the DataSync S3 access roles created by the module, keyed source/destination (null when not created) |
| <a name="output_source_location_arn"></a> [source\_location\_arn](#output\_source\_location\_arn) | Effective ARN of the source location |
| <a name="output_task_arn"></a> [task\_arn](#output\_task\_arn) | ARN of the DataSync task |
| <a name="output_task_id"></a> [task\_id](#output\_task\_id) | ID of the DataSync task |
<!-- END_TF_DOCS -->

## References

- AWS provider docs: [aws_datasync_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task)
