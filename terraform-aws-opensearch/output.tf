output "endpoint" {
  description = "Opensearch endpoint"
  value       = aws_opensearch_domain.this.endpoint
}
