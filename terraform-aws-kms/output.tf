output "key_id" {
  description = "The ID of the KMS key."
  value       = aws_kms_key.this.arn
}

output "key_arn" {
  description = "The ARN of the KMS key."
  value       = aws_kms_key.this.arn
}

output "key_aliases" {
  description = "A map of aliases created and their attributes."
  value       = values(aws_kms_alias.this)[*].id
}

output "iam_policy_kms_encrypt_decrypt_arn" {
  description = "The ARN of the IAM policy that grants encrypt and decrypt permissions for the KMS key."
  value       = try(values(aws_iam_policy.this)[*].arn, [])
}
