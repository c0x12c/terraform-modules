output "arn" {
  description = "The ARN of the load balancer we created"
  value       = aws_lb.main.arn
}

output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records"
  value       = aws_lb.main.zone_id
}

output "listener_https_arn" {
  description = "The ARN of the https listener"
  value       = aws_alb_listener.https.arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.alb.id
}
