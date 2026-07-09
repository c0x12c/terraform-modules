output "task_arn" {
  description = "ARN of the DataSync task"
  value       = module.datasync.task_arn
}

output "source_location_arn" {
  description = "Effective ARN of the source location"
  value       = module.datasync.source_location_arn
}

output "destination_location_arn" {
  description = "Effective ARN of the destination location"
  value       = module.datasync.destination_location_arn
}
