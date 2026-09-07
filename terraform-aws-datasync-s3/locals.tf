data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  create = var.create

  s3_arn_prefix = "arn:${data.aws_partition.current.partition}:s3:::"

  source_bucket_name      = trimprefix(var.source_bucket_arn, local.s3_arn_prefix)
  destination_bucket_name = trimprefix(var.destination_bucket_arn, local.s3_arn_prefix)

  iam_role_name  = coalesce(var.iam_role_name, "${var.name}-datasync")
  log_group_name = coalesce(var.cloudwatch_log_group_name, "/aws/datasync/${var.name}")

  has_schedule = var.schedule_expression != null && var.schedule_expression != ""
  logging      = local.create && var.enable_cloudwatch_logging
}
