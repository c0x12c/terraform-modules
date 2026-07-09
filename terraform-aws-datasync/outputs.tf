output "task_arn" {
  description = "ARN of the DataSync task"
  value       = aws_datasync_task.this.arn
}

output "task_id" {
  description = "ID of the DataSync task"
  value       = aws_datasync_task.this.id
}

output "source_location_arn" {
  description = "Effective ARN of the source location"
  value       = local.source_location_arn
}

output "destination_location_arn" {
  description = "Effective ARN of the destination location"
  value       = local.destination_location_arn
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group wired to the task (null when logging is off)"
  value       = local.cloudwatch_log_group_arn
}

output "s3_access_role_arns" {
  description = "ARNs of the DataSync S3 access roles created by the module, keyed source/destination (null when not created)"
  value = {
    source      = try(aws_iam_role.s3_access["src"].arn, null)
    destination = try(aws_iam_role.s3_access["dst"].arn, null)
  }
}
