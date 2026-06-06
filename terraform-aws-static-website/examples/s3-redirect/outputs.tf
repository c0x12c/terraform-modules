output "domain_name" {
  value = module.static_website.domain_name
}

output "s3_bucket_id" {
  value = module.static_website.s3_bucket_id
}

output "s3_bucket_arn" {
  value = module.static_website.s3_bucket_arn
}

output "cloudfront_id" {
  value = module.static_website.cloudfront_id
}
