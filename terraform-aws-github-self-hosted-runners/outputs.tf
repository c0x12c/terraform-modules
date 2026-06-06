output "aws_launch_template_arn" {
  value       = aws_launch_template.this.arn
  description = "The ARN of the launch template."
}

output "aws_launch_template_id" {
  value       = aws_launch_template.this.id
  description = "The id of the launch template."
}

output "aws_autoscaling_group_arn" {
  value       = aws_autoscaling_group.this.arn
  description = "ARN for this Auto Scaling Group"
}

output "aws_autoscaling_group_id" {
  value       = aws_autoscaling_group.this.id
  description = "Auto Scaling Group id."
}

output "source_instance_id" {
  value       = aws_instance.this.id
  description = "The ID of the source instance."
}

output "custom_ami_id" {
  value       = aws_ami_from_instance.this.id
  description = "The ID of the custom AMI created from the source instance."
}
