output "domain_name" {
  description = "The domain name of the site"
  value       = module.cloudfront.domain_name
}

output "s3_bucket_id" {
  description = "The S3 bucket ID that holding the web assets"
  value       = var.enabled_create_s3 ? module.s3[0].s3_bucket_id : data.aws_s3_bucket.this[0].id
}

output "s3_bucket_arn" {
  description = "The S3 bucket arn that holding the web assets"
  value       = var.enabled_create_s3 ? module.s3[0].s3_bucket_arn : data.aws_s3_bucket.this[0].arn
}

output "cloudfront_id" {
  description = "The Cloudfront ID that hosting the web"
  value       = module.cloudfront.cloudfront_id
}

output "cloudfront_distribution_arn" {
  description = "Cloudfront distribution arn."
  value       = module.cloudfront.cloudfront_distribution_arn
}
