output "cluster" {
  description = "The ECS cluster"
  value       = aws_ecs_cluster.this
}

output "service_connect_namespace_name" {
  value = try(aws_service_discovery_http_namespace.this[0].name, "")
}

output "service_connect_namespace_arn" {
  value = try(aws_service_discovery_http_namespace.this[0].arn, "")
}
