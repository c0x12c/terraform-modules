# AWS MWAA Terraform module

Terraform module for creating and managing Amazon MWAA (Managed Workflows for Apache Airflow) resources on AWS.

This module creates the following components:

- MWAA environment
- IAM role and policies
- S3 bucket (optional)

## Usage

### Create MWAA

```hcl
module "mwaa" {
  source  = "github.com/spartan-stratos/terraform-modules//aws/mwaa?ref=v0.1.52"

  name                         = "example-mwaa-environment"
  private_subnet_ids           = ["subnet-12345", "subnet-67890"]
  source_bucket_arn            = "arn:aws:s3:::example-bucket"
  create_iam_role              = true
  create_s3_bucket             = true
  iam_role_name                = "example-mwaa-role"
  source_bucket_name           = "example-mwaa-bucket"
  dag_s3_path                  = "dags"
  environment_class            = "mw1.medium"
  webserver_access_mode        = "PRIVATE_ONLY"
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 5.75  |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                  | Type        |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                             | resource    |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                                               | resource    |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                                         | resource    |
| [aws_mwaa_environment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mwaa_environment)                                                             | resource    |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                           | resource    |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                   | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource    |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                     | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                                         | data source |
| [aws_iam_policy_document.mwaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                    | data source |
| [aws_iam_policy_document.mwaa_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                             | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)                                                                     | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                                           | data source |

## Inputs

| Name                                                                                                                                       | Description                                                                                                                                                                                                                                                    | Type           | Default          | Required |
|--------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|------------------|:--------:|
| <a name="input_additional_principal_arns"></a> [additional\_principal\_arns](#input\_additional\_principal\_arns)                          | List of additional AWS principal ARNs                                                                                                                                                                                                                          | `list(string)` | `[]`             |    no    |
| <a name="input_airflow_configuration_options"></a> [airflow\_configuration\_options](#input\_airflow\_configuration\_options)              | (Optional) The airflow\_configuration\_options parameter specifies airflow override options.                                                                                                                                                                   | `any`          | `null`           |    no    |
| <a name="input_airflow_version"></a> [airflow\_version](#input\_airflow\_version)                                                          | (Optional) Airflow version of your environment, will be set by default to the latest version that MWAA supports.                                                                                                                                               | `string`       | `null`           |    no    |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role)                                                        | Create IAM role for MWAA                                                                                                                                                                                                                                       | `bool`         | `true`           |    no    |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket)                                                     | Create new S3 bucket for MWAA.                                                                                                                                                                                                                                 | `string`       | `true`           |    no    |
| <a name="input_dag_s3_path"></a> [dag\_s3\_path](#input\_dag\_s3\_path)                                                                    | (Required) The relative path to the DAG folder on your Amazon S3 storage bucket. For example, dags.                                                                                                                                                            | `string`       | `"dags"`         |    no    |
| <a name="input_environment_class"></a> [environment\_class](#input\_environment\_class)                                                    | (Optional) Environment class for the cluster. Possible options are mw1.small, mw1.medium, mw1.large, mw1.xlarge, mw1.2xlarge.<br/>Will be set by default to mw1.small. Please check the AWS Pricing for more information about the environment classes.        | `string`       | `"mw1.small"`    |    no    |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn)                                               | (Required) The Amazon Resource Name (ARN) of the task execution role that the Amazon MWAA and its environment can assume<br/>Mandatory if `create_iam_role=false`                                                                                              | `string`       | `null`           |    no    |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies)               | Additional policies to be added to the IAM role                                                                                                                                                                                                                | `map(string)`  | `{}`             |    no    |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name)                                                              | IAM Role Name to be created if execution\_role\_arn is null                                                                                                                                                                                                    | `string`       | `null`           |    no    |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key)                                                                                  | (Optional) The Amazon Resource Name (ARN) of your KMS key that you want to use for encryption.<br/>Will be set to the ARN of the managed KMS key aws/airflow by default.                                                                                       | `string`       | `null`           |    no    |
| <a name="input_logging_configuration"></a> [logging\_configuration](#input\_logging\_configuration)                                        | (Optional) The Apache Airflow logs which will be send to Amazon CloudWatch Logs.                                                                                                                                                                               | `any`          | `null`           |    no    |
| <a name="input_max_workers"></a> [max\_workers](#input\_max\_workers)                                                                      | (Optional) The maximum number of workers that can be automatically scaled up.<br/>Value need to be between 1 and 25. Will be 10 by default                                                                                                                     | `number`       | `10`             |    no    |
| <a name="input_min_workers"></a> [min\_workers](#input\_min\_workers)                                                                      | (Optional) The minimum number of workers that you want to run in your environment. Will be 1 by default.                                                                                                                                                       | `number`       | `1`              |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                                             | (Required) The name of the Apache Airflow MWAA Environment                                                                                                                                                                                                     | `string`       | n/a              |   yes    |
| <a name="input_plugins_s3_object_version"></a> [plugins\_s3\_object\_version](#input\_plugins\_s3\_object\_version)                        | (Optional) The plugins.zip file version you want to use.                                                                                                                                                                                                       | `string`       | `null`           |    no    |
| <a name="input_plugins_s3_path"></a> [plugins\_s3\_path](#input\_plugins\_s3\_path)                                                        | (Optional) The relative path to the plugins.zip file on your Amazon S3 storage bucket. For example, plugins.zip. If a relative path is provided in the request, then plugins\_s3\_object\_version is required.                                                 | `string`       | `null`           |    no    |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids)                                               | (Required) The private subnet IDs in which the environment should be created.<br/>MWAA requires two subnets.                                                                                                                                                   | `list(string)` | n/a              |   yes    |
| <a name="input_requirements_s3_object_version"></a> [requirements\_s3\_object\_version](#input\_requirements\_s3\_object\_version)         | (Optional) The requirements.txt file version you want to use.                                                                                                                                                                                                  | `string`       | `null`           |    no    |
| <a name="input_requirements_s3_path"></a> [requirements\_s3\_path](#input\_requirements\_s3\_path)                                         | (Optional) The relative path to the requirements.txt file on your Amazon S3 storage bucket. For example, requirements.txt. If a relative path is provided in the request, then requirements\_s3\_object\_version is required.                                  | `string`       | `null`           |    no    |
| <a name="input_schedulers"></a> [schedulers](#input\_schedulers)                                                                           | (Optional) The number of schedulers that you want to run in your environment.                                                                                                                                                                                  | `string`       | `null`           |    no    |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids)                                               | Security group IDs for MWAA                                                                                                                                                                                                                                    | `list(string)` | `[]`             |    no    |
| <a name="input_source_bucket_arn"></a> [source\_bucket\_arn](#input\_source\_bucket\_arn)                                                  | (Required) The Amazon Resource Name (ARN) of your Amazon S3 storage bucket. For example, arn:aws:s3:::airflow-mybucketname                                                                                                                                     | `string`       | `null`           |    no    |
| <a name="input_source_bucket_name"></a> [source\_bucket\_name](#input\_source\_bucket\_name)                                               | New bucket will be created with the given name for MWAA when create\_s3\_bucket=true.<br/>If set to null, then the default bucket name prefix will be set, irrespective of the value of `var.use_source_bucket_name_as_prefix`                                 | `string`       | `null`           |    no    |
| <a name="input_startup_script_s3_object_version"></a> [startup\_script\_s3\_object\_version](#input\_startup\_script\_s3\_object\_version) | (Optional) The version of the startup shell script you want to use. You must specify the version ID that Amazon S3 assigns to the file every time you update the script.                                                                                       | `string`       | `null`           |    no    |
| <a name="input_startup_script_s3_path"></a> [startup\_script\_s3\_path](#input\_startup\_script\_s3\_path)                                 | (Optional) The relative path to the script hosted in your bucket. The script runs as your environment starts before starting the Apache Airflow process. Use this script to install dependencies, modify configuration options, and set environment variables. | `string`       | `null`           |    no    |
| <a name="input_webserver_access_mode"></a> [webserver\_access\_mode](#input\_webserver\_access\_mode)                                      | (Optional) Specifies whether the webserver should be accessible over the internet or via your specified VPC. Possible options: PRIVATE\_ONLY (default) and PUBLIC\_ONLY                                                                                        | `string`       | `"PRIVATE_ONLY"` |    no    |
| <a name="input_weekly_maintenance_window_start"></a> [weekly\_maintenance\_window\_start](#input\_weekly\_maintenance\_window\_start)      | (Optional) Specifies the start date for the weekly maintenance window                                                                                                                                                                                          | `string`       | `null`           |    no    |

## Outputs

| Name                                                                                                      | Description                                         |
|-----------------------------------------------------------------------------------------------------------|-----------------------------------------------------|
| <a name="output_aws_s3_bucket_name"></a> [aws\_s3\_bucket\_name](#output\_aws\_s3\_bucket\_name)          | S3 bucket Name of the MWAA Environment              |
| <a name="output_mwaa_arn"></a> [mwaa\_arn](#output\_mwaa\_arn)                                            | The ARN of the MWAA Environment                     |
| <a name="output_mwaa_role_arn"></a> [mwaa\_role\_arn](#output\_mwaa\_role\_arn)                           | IAM Role ARN of the MWAA Environment                |
| <a name="output_mwaa_role_name"></a> [mwaa\_role\_name](#output\_mwaa\_role\_name)                        | IAM role name of the MWAA Environment               |
| <a name="output_mwaa_service_role_arn"></a> [mwaa\_service\_role\_arn](#output\_mwaa\_service\_role\_arn) | The Service Role ARN of the Amazon MWAA Environment |
| <a name="output_mwaa_status"></a> [mwaa\_status](#output\_mwaa\_status)                                   | The status of the Amazon MWAA Environment           |
| <a name="output_mwaa_webserver_url"></a> [mwaa\_webserver\_url](#output\_mwaa\_webserver\_url)            | The webserver URL of the MWAA Environment           |

<!-- END_TF_DOCS -->