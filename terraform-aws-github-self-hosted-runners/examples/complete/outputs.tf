output "aws_launch_template_arn" {
  value       = module.github_self_host_runner.aws_launch_template_arn
  description = "The ARN of the launch template."
}

output "aws_launch_template_id" {
  value       = module.github_self_host_runner.aws_launch_template_id
  description = "The id of the launch template."
}

output "aws_autoscaling_group_arn" {
  value       = module.github_self_host_runner.aws_autoscaling_group_arn
  description = "ARN for this Auto Scaling Group"
}

output "aws_autoscaling_group_id" {
  value       = module.github_self_host_runner.aws_autoscaling_group_id
  description = "Auto Scaling Group id."
}

output "source_instance_id" {
  value       = module.github_self_host_runner.source_instance_id
  description = "The ID of the source instance."
}

output "custom_ami_id" {
  value       = module.github_self_host_runner.custom_ami_id
  description = "The ID of the custom AMI created from the source instance."
}
