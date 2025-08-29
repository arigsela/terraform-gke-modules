variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "hostname" {
  description = "Hostname for ArgoCD server"
  type        = string
}

variable "node_selector" {
  description = "Node selector for ArgoCD pods"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for ArgoCD pods"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "ingress_class" {
  description = "Ingress class name"
  type        = string
  default     = "nginx"
}

variable "cert_issuer" {
  description = "Cert-manager cluster issuer"
  type        = string
  default     = "letsencrypt-prod"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "workload_identity_enabled" {
  description = "Enable Workload Identity integration"
  type        = bool
  default     = true
}

variable "workload_identity_service_account" {
  description = "GCP service account for Workload Identity"
  type        = string
  default     = ""
}

variable "enable_applicationset" {
  description = "Enable ApplicationSet configuration"
  type        = bool
  default     = true
}

variable "repository_url" {
  description = "Git repository URL for ApplicationSet"
  type        = string
  default     = "https://github.com/arigsela/kubernetes"
}

variable "applications_path" {
  description = "Base path in repository containing applications"
  type        = string
  default     = "appset-base-apps"
}