output "access_entry_arn" {
  value       = { for access_entry in aws_eks_access_entry.this : access_entry.principal_arn => access_entry.access_entry_arn }
  description = "Map of principal_arn to the associated access entry ARN for each access entry in the AWS EKS cluster"
}
