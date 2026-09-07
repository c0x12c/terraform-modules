output "task_arn" {
  description = "ARN of the DataSync task. Run it with `aws datasync start-task-execution --task-arn`."
  value       = try(aws_datasync_task.this[0].arn, null)
}

output "task_name" {
  description = "Name of the DataSync task."
  value       = try(aws_datasync_task.this[0].name, null)
}

output "iam_role_arn" {
  description = "ARN of the role DataSync assumes. Grant it read access in a cross-account source bucket policy."
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_name" {
  description = "Name of the role DataSync assumes."
  value       = try(aws_iam_role.this[0].name, null)
}

output "source_location_arn" {
  description = "ARN of the source S3 location."
  value       = try(aws_datasync_location_s3.source[0].arn, null)
}

output "destination_location_arn" {
  description = "ARN of the destination S3 location."
  value       = try(aws_datasync_location_s3.destination[0].arn, null)
}

output "source_bucket_name" {
  description = "Name of the source bucket."
  value       = local.source_bucket_name
}

output "destination_bucket_name" {
  description = "Name of the destination bucket."
  value       = local.destination_bucket_name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group receiving transfer errors."
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group receiving transfer errors."
  value       = try(aws_cloudwatch_log_group.this[0].arn, null)
}

output "task_report_s3_uri" {
  description = "s3:// prefix the task reports are written to."
  value       = var.enable_task_report ? "s3://${local.destination_bucket_name}${var.task_report_subdirectory}/" : null
}
