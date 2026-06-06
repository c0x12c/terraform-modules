output "artifact_id" {
  description = "An identifier for the resource with format `projects/{{project}}/locations/{{location}}/repositories/{{repository_id}}`."
  value       = google_artifact_registry_repository.this.id
}

output "artifact_name" {
  description = "The name of the repository created from input repository_id."
  value       = google_artifact_registry_repository.this.name
}
