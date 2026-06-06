output "security_group_ids" {
  description = "Map of security group names to their IDs"
  value       = { for sg in aws_security_group.this : sg.name => sg.id }
}

output "security_group_allow_all_id" {
  description = "The ID of the 'allow all' security group."
  value       = try(aws_security_group.allow_all[0].id, null)
}

output "security_group_allow_all_within_vpc_id" {
  description = "The ID of the 'allow all within VPC' security group."
  value       = try(aws_security_group.allow_all_within_vpc[0].id, null)
}
