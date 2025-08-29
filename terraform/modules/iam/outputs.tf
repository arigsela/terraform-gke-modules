output "workload_identity_service_account_email" {
  description = "Email of the workload identity service account"
  value       = var.create_workload_identity_sa ? google_service_account.workload_identity[0].email : null
}

output "workload_identity_service_account_name" {
  description = "Name of the workload identity service account"
  value       = var.create_workload_identity_sa ? google_service_account.workload_identity[0].name : null
}

output "workload_identity_service_account_id" {
  description = "ID of the workload identity service account"
  value       = var.create_workload_identity_sa ? google_service_account.workload_identity[0].unique_id : null
}

output "gke_node_service_account_email" {
  description = "Email of the GKE node service account"
  value       = var.create_gke_node_sa ? google_service_account.gke_node_sa[0].email : null
}

output "gke_node_service_account_name" {
  description = "Name of the GKE node service account"
  value       = var.create_gke_node_sa ? google_service_account.gke_node_sa[0].name : null
}

output "gke_node_service_account_id" {
  description = "ID of the GKE node service account"
  value       = var.create_gke_node_sa ? google_service_account.gke_node_sa[0].unique_id : null
}

output "workload_identity_key" {
  description = "Private key for workload identity service account"
  value       = var.create_workload_identity_key ? google_service_account_key.workload_identity_key[0].private_key : null
  sensitive   = true
}

output "gke_node_key" {
  description = "Private key for GKE node service account"
  value       = var.create_gke_node_key ? google_service_account_key.gke_node_key[0].private_key : null
  sensitive   = true
}

output "custom_role_ids" {
  description = "Map of custom role IDs"
  value       = { for k, v in google_project_iam_custom_role.custom_roles : k => v.role_id }
}