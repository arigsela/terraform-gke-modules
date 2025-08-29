variable "argocd_namespace" {
  description = "Namespace where ArgoCD is deployed"
  type        = string
  default     = "argocd"
}

variable "repository_url" {
  description = "Git repository URL containing applications"
  type        = string
  default     = "https://github.com/arigsela/kubernetes"
}

variable "applications_path" {
  description = "Base path in repository containing applications"
  type        = string
  default     = "appset-base-apps"
}

variable "project_name" {
  description = "ArgoCD project name"
  type        = string
  default     = "production"
}

variable "sync_policy" {
  description = "Application sync policy configuration"
  type = object({
    automated = object({
      prune     = bool
      self_heal = bool
    })
    sync_options = list(string)
  })
  default = {
    automated = {
      prune     = true
      self_heal = true
    }
    sync_options = [
      "CreateNamespace=true"
    ]
  }
}

variable "destination_server" {
  description = "Kubernetes cluster server URL"
  type        = string
  default     = "https://kubernetes.default.svc"
}

variable "target_revision" {
  description = "Git branch/tag to track"
  type        = string
  default     = "HEAD"
}