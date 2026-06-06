output "arn" {
  description = "The ARN assigned by AWS for this provider"
  value       = length(aws_iam_openid_connect_provider.this) > 0 ? aws_iam_openid_connect_provider.this[0].arn : data.aws_iam_openid_connect_provider.this[0].arn
}

output "url" {
  description = "The URL of the identity provider. Corresponds to the iss claim"
  value       = length(aws_iam_openid_connect_provider.this) > 0 ? aws_iam_openid_connect_provider.this[0].url : data.aws_iam_openid_connect_provider.this[0].url
}
