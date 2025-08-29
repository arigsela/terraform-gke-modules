output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.name
}

output "cluster_location" {
  description = "GKE cluster location"
  value       = module.gke.location
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = module.artifact_registry.repository_url
}

output "workload_identity_service_account" {
  description = "Workload Identity service account email"
  value       = module.iam.workload_identity_service_account_email
}