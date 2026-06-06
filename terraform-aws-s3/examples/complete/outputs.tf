output "s3_bucket_id" {
  value = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  value = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_name" {
  value = module.s3_bucket.s3_bucket_name
}

output "s3_bucket_regional_domain_name" {
  value = module.s3_bucket.s3_bucket_regional_domain_name
}

output "iam_policy_s3_bucket_public_assets_write_arn" {
  value = module.s3_bucket.iam_policy_s3_bucket_public_assets_write_arn
}

output "iam_policy_s3_bucket_assets_read_only_arn" {
  value = module.s3_bucket.iam_policy_s3_bucket_assets_read_only_arn
}
