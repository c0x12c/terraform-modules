output "expire_passwords" {
  value       = aws_iam_account_password_policy.this.expire_passwords
  description = "Indicates whether passwords expire as per the account password policy"
}
