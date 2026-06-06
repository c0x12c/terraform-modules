output "mwaa_webserver_url" {
  description = "The webserver URL of the MWAA Environment"
  value       = aws_mwaa_environment.this.webserver_url
}

output "mwaa_arn" {
  description = "The ARN of the MWAA Environment"
  value       = aws_mwaa_environment.this.arn
}

output "mwaa_service_role_arn" {
  description = "The Service Role ARN of the Amazon MWAA Environment"
  value       = aws_mwaa_environment.this.service_role_arn
}

output "mwaa_status" {
  description = "The status of the Amazon MWAA Environment"
  value       = aws_mwaa_environment.this.status
}

output "mwaa_role_arn" {
  description = "IAM Role ARN of the MWAA Environment"
  value       = var.execution_role_arn == null ? aws_iam_role.this[0].arn : ""
}

output "mwaa_role_name" {
  description = "IAM role name of the MWAA Environment"
  value       = var.execution_role_arn == null ? aws_iam_role.this[0].id : ""
}

output "aws_s3_bucket_name" {
  description = "S3 bucket Name of the MWAA Environment"
  value       = var.source_bucket_arn == null ? aws_s3_bucket.this[0].id : ""
}
