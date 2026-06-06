output "arn" {
  description = "The ARN of the Cloudtrail."
  value       = aws_cloudtrail.this.arn
}

output "s3_bucket_id" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}
