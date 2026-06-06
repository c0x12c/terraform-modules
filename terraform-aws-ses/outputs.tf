output "domain_identity_arn" {
  value       = aws_ses_domain_identity.this.arn
  description = "The ARN of the SES domain identity."
}

output "iam_policy_ses_send_email" {
  value = aws_iam_policy.this.arn
}

output "domain_identity_id" {
  value = aws_ses_domain_identity.this.id
}

output "email_identity_ids" {
  value = { for k, v in aws_ses_email_identity.emails : v.email => v.id }
}
