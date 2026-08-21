output "domain_name" {
  value = { for k, m in module.static_website : k => m.domain_name }
}

output "s3_bucket_id" {
  value = { for k, m in module.static_website : k => m.s3_bucket_id }
}

output "s3_bucket_arn" {
  value = { for k, m in module.static_website : k => m.s3_bucket_arn }
}

output "cloudfront_id" {
  value = { for k, m in module.static_website : k => m.cloudfront_id }
}
