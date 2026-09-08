output "task_arn" {
  description = "Start the transfer with: aws datasync start-task-execution --task-arn <this>"
  value       = module.s3_datasync.task_arn
}

output "iam_role_arn" {
  description = "Grant this role read access in the source bucket policy when the source is cross-account."
  value       = module.s3_datasync.iam_role_arn
}

output "task_report_s3_uri" {
  value = module.s3_datasync.task_report_s3_uri
}
