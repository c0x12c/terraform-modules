output "pod_role" {
  value       = aws_iam_role.this.arn
  description = "The ARN of the IAM role for services' pods"
}

output "service_hostnames" {
  description = "This output generates a map of service hostnames by iterating over the Route 53 records and extracting their fully qualified domain names (FQDNs). Each key corresponds to a unique identifier, and its value is the associated FQDN."
  value = {
    for k, hostname in aws_route53_record.this : k => hostname.fqdn
  }
}
