output "endpoint" {
  value = module.cluster.endpoint
}

output "iam_auth_policy_arn" {
  value = module.cluster.iam_auth_policy_arn
}
