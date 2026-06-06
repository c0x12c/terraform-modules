output "s3_bucket_id" {
  description = "The unique ID of the S3 bucket"
  value       = local.bucket.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = local.bucket.arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = local.bucket.bucket
}

output "s3_bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  value       = local.bucket.bucket_regional_domain_name
}

output "iam_policy_s3_bucket_public_assets_write_arn" {
  description = "The ARN of the IAM policy granting write access only to S3 bucket assets."
  value       = try(aws_iam_policy.this.0.arn, null)
}

output "iam_policy_s3_bucket_assets_read_write_arn" {
  description = "The ARN of the IAM policy granting read write access to the S3 bucket assets."
  value       = try(aws_iam_policy.read_write.0.arn, null)
}

output "iam_policy_s3_bucket_assets_read_only_arn" {
  description = "The ARN of the IAM policy granting read-only access to the S3 bucket assets"
  value       = try(aws_iam_policy.readonly.0.arn, null)
}
