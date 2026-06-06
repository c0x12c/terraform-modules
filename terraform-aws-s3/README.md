# AWS S3 Terraform module

Terraform module which creates S3 resources on AWS.

This module will create:

- S3 bucket with alongside configuration and policy
- Two IAM policy for reading and writing to the bucket objects

## Usage

### Create S3

```hcl
module "s3" {
  source = "github.com/spartan-stratos/terraform-modules//aws/s3?ref=v0.3.17"

  bucket_name     = "example-bucket"
  allowed_origins = ["example.com"]
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.read_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_s3_bucket.with_prefix](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.without_prefix](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.read_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.readonly_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log_target_bucket_id"></a> [access\_log\_target\_bucket\_id](#input\_access\_log\_target\_bucket\_id) | The bucket ID to store the access logs | `string` | `null` | no |
| <a name="input_access_log_target_prefix"></a> [access\_log\_target\_prefix](#input\_access\_log\_target\_prefix) | The target prefix for the access logs | `string` | `null` | no |
| <a name="input_access_logs_bucket_arn"></a> [access\_logs\_bucket\_arn](#input\_access\_logs\_bucket\_arn) | The arn of bucket that stores access logs | `string` | `null` | no |
| <a name="input_acl"></a> [acl](#input\_acl) | Canned ACL to apply to the bucket. Support private and public-read. | `string` | `"private"` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Whether Amazon S3 should block public ACLs for this bucket. | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for this bucket. | `bool` | `true` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The bucket name to be created. | `string` | `null` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | The bucket prefix to be created. | `string` | `null` | no |
| <a name="input_cors_configuration"></a> [cors\_configuration](#input\_cors\_configuration) | Configuration for CORS settings | <pre>object({<br/>    allowed_headers = optional(list(string))<br/>    expose_headers  = optional(list(string))<br/>    allowed_methods = list(string)<br/>    allowed_origins = list(string)<br/>    max_age_seconds = optional(number)<br/>  })</pre> | <pre>{<br/>  "allowed_headers": [],<br/>  "allowed_methods": [],<br/>  "allowed_origins": [],<br/>  "expose_headers": [],<br/>  "max_age_seconds": 3600<br/>}</pre> | no |
| <a name="input_create_bucket_policy"></a> [create\_bucket\_policy](#input\_create\_bucket\_policy) | Whether to create bucket policy. | `bool` | `true` | no |
| <a name="input_custom_bucket_policies"></a> [custom\_bucket\_policies](#input\_custom\_bucket\_policies) | List of custom bucket policy statements appended to the bucket policy document. Each entry follows the aws\_iam\_policy\_document statement shape. | <pre>list(object({<br/>    sid       = string<br/>    effect    = string<br/>    actions   = list(string)<br/>    resources = optional(list(string))<br/>    principals = optional(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    }))<br/>    conditions = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_custom_read_write_policy_name"></a> [custom\_read\_write\_policy\_name](#input\_custom\_read\_write\_policy\_name) | The custom read write policy name to overwrite default one | `string` | `null` | no |
| <a name="input_custom_readonly_policy_name"></a> [custom\_readonly\_policy\_name](#input\_custom\_readonly\_policy\_name) | The custom read only policy name to overwrite default one | `string` | `null` | no |
| <a name="input_disabled_s3_http_access"></a> [disabled\_s3\_http\_access](#input\_disabled\_s3\_http\_access) | Whether to restrict HTTP access to S3 bucket. | `bool` | `true` | no |
| <a name="input_enabled_cors"></a> [enabled\_cors](#input\_enabled\_cors) | Enable to configure the CORS | `bool` | `false` | no |
| <a name="input_enabled_iam_policy"></a> [enabled\_iam\_policy](#input\_enabled\_iam\_policy) | Enabled create the IAM Policies. | `bool` | `false` | no |
| <a name="input_enabled_public_policy"></a> [enabled\_public\_policy](#input\_enabled\_public\_policy) | Enabled create the Public Policy to allow public access to bucket objects. | `bool` | `false` | no |
| <a name="input_enabled_read_only_policy"></a> [enabled\_read\_only\_policy](#input\_enabled\_read\_only\_policy) | Enabled create the Read Only Policy to allow access to bucket objects. | `bool` | `false` | no |
| <a name="input_enabled_read_write_policy"></a> [enabled\_read\_write\_policy](#input\_enabled\_read\_write\_policy) | Enabled create the Read Write Policy to allow access to bucket objects. | `bool` | `false` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Enable to force destroy the bucket. | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for this bucket. | `bool` | `true` | no |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | Object ownership. Valid values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced | `string` | `null` | no |
| <a name="input_public_policy_description"></a> [public\_policy\_description](#input\_public\_policy\_description) | Description for public policy | `string` | `"Policy that allows writing to the s3 public assets bucket"` | no |
| <a name="input_public_policy_name_prefix"></a> [public\_policy\_name\_prefix](#input\_public\_policy\_name\_prefix) | The name prefix for the public policy | `string` | `"S3PublicAssetsWrite"` | no |
| <a name="input_read_write_actions"></a> [read\_write\_actions](#input\_read\_write\_actions) | Read write policy actions | `list(string)` | <pre>[<br/>  "s3:DeleteObject",<br/>  "s3:GetObject",<br/>  "s3:GetObjectAcl",<br/>  "s3:ListBucket",<br/>  "s3:ObjectOwnerOverrideToBucketOwner",<br/>  "s3:PutObject",<br/>  "s3:PutObjectAcl"<br/>]</pre> | no |
| <a name="input_read_write_policy_description"></a> [read\_write\_policy\_description](#input\_read\_write\_policy\_description) | Description for read write policy | `string` | `"Policy that allows writing to the S3 bucket"` | no |
| <a name="input_read_write_policy_name_prefix"></a> [read\_write\_policy\_name\_prefix](#input\_read\_write\_policy\_name\_prefix) | The name prefix for the read write policy | `string` | `"S3ReadWrite"` | no |
| <a name="input_readonly_policy_description"></a> [readonly\_policy\_description](#input\_readonly\_policy\_description) | Description for readonly policy | `string` | `"Policy that allows reading from the s3 assets bucket"` | no |
| <a name="input_readonly_policy_name_prefix"></a> [readonly\_policy\_name\_prefix](#input\_readonly\_policy\_name\_prefix) | The name prefix for the readonly policy | `string` | `"S3AssetsRead"` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for this bucket. | `bool` | `true` | no |
| <a name="input_s3_lifecycle_rules"></a> [s3\_lifecycle\_rules](#input\_s3\_lifecycle\_rules) | List of S3 bucket lifecycle configuration. | <pre>list(object({<br/>    id              = string<br/>    status          = string               # "Enabled" or "Disabled"<br/>    filter_prefix   = optional(string, "") # "" will apply to all<br/>    transition_days = optional(number, 0)<br/>    expiration_days = number<br/>    storage_class   = string # "STANDARD_IA", "DEEP_ARCHIVE", "GLACIER", ...<br/>  }))</pre> | `null` | no |
| <a name="input_versioning_status"></a> [versioning\_status](#input\_versioning\_status) | The status of bucket versioning. | `string` | `"Disabled"` | no |
| <a name="input_write_access_logs_source_bucket_arns"></a> [write\_access\_logs\_source\_bucket\_arns](#input\_write\_access\_logs\_source\_bucket\_arns) | If specified, the bucket will have a policy that allows the specified source buckets to write access logs to it. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_policy_s3_bucket_assets_read_only_arn"></a> [iam\_policy\_s3\_bucket\_assets\_read\_only\_arn](#output\_iam\_policy\_s3\_bucket\_assets\_read\_only\_arn) | The ARN of the IAM policy granting read-only access to the S3 bucket assets |
| <a name="output_iam_policy_s3_bucket_assets_read_write_arn"></a> [iam\_policy\_s3\_bucket\_assets\_read\_write\_arn](#output\_iam\_policy\_s3\_bucket\_assets\_read\_write\_arn) | The ARN of the IAM policy granting read write access to the S3 bucket assets. |
| <a name="output_iam_policy_s3_bucket_public_assets_write_arn"></a> [iam\_policy\_s3\_bucket\_public\_assets\_write\_arn](#output\_iam\_policy\_s3\_bucket\_public\_assets\_write\_arn) | The ARN of the IAM policy granting write access only to S3 bucket assets. |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the S3 bucket |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The unique ID of the S3 bucket |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | The name of the S3 bucket |
| <a name="output_s3_bucket_regional_domain_name"></a> [s3\_bucket\_regional\_domain\_name](#output\_s3\_bucket\_regional\_domain\_name) | The regional domain name of the S3 bucket |
<!-- END_TF_DOCS -->
