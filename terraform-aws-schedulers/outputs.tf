output "scheduler_arn" {
  description = "The ARN of the scheduler schedule"
  value       = aws_scheduler_schedule.this.arn
}

output "scheduler_role_arn" {
  description = "The ARN of the IAM role associated with the scheduler"
  value       = aws_iam_role.this.arn
}

output "iam_policy_access_scheduler_arn" {
  description = "The ARN of the IAM policy for accessing the scheduler"
  value       = aws_iam_policy.this.arn
}
