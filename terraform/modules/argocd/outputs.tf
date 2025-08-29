output "namespace" {
  description = "ArgoCD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "server_url" {
  description = "ArgoCD server URL"
  value       = "https://${var.hostname}"
}

output "admin_password_command" {
  description = "Command to get admin password"
  value       = "kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "applicationset_enabled" {
  description = "Whether ApplicationSet is enabled"
  value       = var.enable_applicationset
}

output "repository_url" {
  description = "Git repository URL for ApplicationSet"
  value       = var.enable_applicationset ? var.repository_url : null
}

output "applications_path" {
  description = "Base path for applications in repository"
  value       = var.enable_applicationset ? var.applications_path : null
}

output "project_name" {
  description = "ArgoCD project name"
  value       = var.enable_applicationset ? "production" : null
}