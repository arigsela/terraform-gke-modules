variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "chores-tracker-prod"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "node_locations" {
  description = "List of zones for GKE nodes"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}