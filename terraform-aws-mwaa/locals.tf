locals {
  execution_role_arn = var.create_iam_role ? aws_iam_role.this[0].arn : var.execution_role_arn

  source_bucket_arn = var.create_s3_bucket ? aws_s3_bucket.this[0].arn : var.source_bucket_arn

  default_airflow_configuration_options = {
    "logging.logging_level" = "INFO"
  }

  iam_role_additional_policies = { for k, v in var.iam_role_additional_policies : k => v if var.create_iam_role }
}
