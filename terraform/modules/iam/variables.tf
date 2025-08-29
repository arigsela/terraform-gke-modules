variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "create_workload_identity_sa" {
  description = "Whether to create a workload identity service account"
  type        = bool
  default     = true
}

variable "workload_identity_sa_name" {
  description = "Name of the workload identity service account"
  type        = string
  default     = "workload-identity-sa"
}

variable "workload_identity_sa_display_name" {
  description = "Display name of the workload identity service account"
  type        = string
  default     = "Workload Identity Service Account"
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for workload identity binding"
  type        = string
  default     = "default"
}

variable "kubernetes_service_account" {
  description = "Kubernetes service account for workload identity binding"
  type        = string
  default     = "default"
}

variable "workload_identity_roles" {
  description = "List of IAM roles to assign to the workload identity service account"
  type        = list(string)
  default     = []
}

variable "create_gke_node_sa" {
  description = "Whether to create a GKE node service account"
  type        = bool
  default     = true
}

variable "gke_node_sa_name" {
  description = "Name of the GKE node service account"
  type        = string
  default     = "gke-node-sa"
}

variable "gke_node_sa_display_name" {
  description = "Display name of the GKE node service account"
  type        = string
  default     = "GKE Node Service Account"
}

variable "gke_node_roles" {
  description = "List of IAM roles to assign to the GKE node service account"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ]
}

variable "custom_roles" {
  description = "Map of custom IAM roles to create"
  type = map(object({
    title       = string
    description = string
    permissions = list(string)
    stage       = string
  }))
  default = {}
}

variable "project_iam_bindings" {
  description = "Map of IAM role bindings at the project level"
  type        = map(list(string))
  default     = {}
}

variable "create_workload_identity_key" {
  description = "Whether to create a key for the workload identity service account"
  type        = bool
  default     = false
}

variable "create_gke_node_key" {
  description = "Whether to create a key for the GKE node service account"
  type        = bool
  default     = false
}