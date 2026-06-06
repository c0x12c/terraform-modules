output "scheduler_arn" {
  value = module.aws_scheduler.scheduler_arn
}

output "scheduler_role_arn" {
  value = module.aws_scheduler.scheduler_role_arn
}

output "iam_policy_access_scheduler_arn" {
  value = module.aws_scheduler.iam_policy_access_scheduler_arn
}
