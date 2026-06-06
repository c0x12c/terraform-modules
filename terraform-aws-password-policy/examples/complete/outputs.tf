output "expire_passwords" {
  value       = module.password_policy.expire_passwords
  description = "Indicates whether passwords expire as per the account password policy"
}
