output "node_role_arn" {
  value = aws_iam_role.this.arn
}

output "managed_node_group" {
  value = aws_eks_node_group.this
}
