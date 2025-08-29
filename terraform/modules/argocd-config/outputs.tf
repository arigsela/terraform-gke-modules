output "project_name" {
  description = "ArgoCD project name"
  value       = var.project_name
}

output "repository_url" {
  description = "Configured repository URL"
  value       = var.repository_url
}

output "applicationset_name" {
  description = "ApplicationSet name"
  value       = "${var.project_name}-apps"
}

output "applications_path" {
  description = "Base path for applications in repository"
  value       = var.applications_path
}