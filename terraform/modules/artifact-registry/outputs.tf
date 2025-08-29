output "repository_id" {
  description = "The ID of the repository"
  value       = google_artifact_registry_repository.repo.repository_id
}

output "name" {
  description = "The name of the repository"
  value       = google_artifact_registry_repository.repo.name
}

output "location" {
  description = "The location of the repository"
  value       = google_artifact_registry_repository.repo.location
}

output "repository_url" {
  description = "The URL of the repository"
  value       = "${google_artifact_registry_repository.repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}

output "create_time" {
  description = "The time when the repository was created"
  value       = google_artifact_registry_repository.repo.create_time
}

output "update_time" {
  description = "The time when the repository was last updated"
  value       = google_artifact_registry_repository.repo.update_time
}