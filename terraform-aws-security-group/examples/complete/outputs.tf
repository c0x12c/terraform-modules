output "security_group_ids" {
  description = "Security group IDs created by the module"
  value       = module.aws_default_security_groups.security_group_ids
}

output "security_group_allow_all_id" {
  description = "The ID of the 'allow all' security group."
  value       = module.aws_custom_security_groups.security_group_allow_all_id
}

output "security_group_allow_all_within_vpc_id" {
  description = "The ID of the 'allow all within VPC' security group."
  value       = module.aws_custom_security_groups.security_group_allow_all_within_vpc_id
}
