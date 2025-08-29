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

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = module.artifact_registry.repository_url
}

output "ingress_ip" {
  description = "Static IP for ingress"
  value       = google_compute_global_address.ingress_ip.address
}

output "workload_identity_service_account" {
  description = "Workload Identity service account email"
  value       = module.iam.workload_identity_service_account_email
}

output "gke_node_service_account" {
  description = "GKE node service account email"
  value       = module.iam.gke_node_service_account_email
}

output "vpc_network_name" {
  description = "VPC network name"
  value       = module.vpc.network_name
}

output "subnet_name" {
  description = "Subnet name"
  value       = module.vpc.subnets["gke-subnet-prod"].name
}