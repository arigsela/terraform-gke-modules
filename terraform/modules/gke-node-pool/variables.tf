variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "The name of the node pool"
  type        = string
}

variable "location" {
  description = "The location of the cluster"
  type        = string
}

variable "cluster" {
  description = "The cluster to create the node pool for"
  type        = string
}

variable "node_count" {
  description = "The initial number of nodes for the pool"
  type        = number
  default     = 1
}

variable "autoscaling" {
  description = "Configuration for cluster autoscaling"
  type = object({
    enabled        = bool
    min_node_count = number
    max_node_count = number
  })
  default = {
    enabled        = true
    min_node_count = 1
    max_node_count = 3
  }
}

variable "node_config" {
  description = "Node configuration"
  type = object({
    machine_type   = string
    disk_size_gb   = number
    disk_type      = string
    image_type     = string
    preemptible    = bool
    spot           = bool
    service_account = string
    oauth_scopes   = list(string)
    labels         = map(string)
    tags           = list(string)
    taint = list(object({
      key    = string
      value  = string
      effect = string
    }))
    metadata                     = map(string)
    workload_metadata_mode       = string
    enable_shielded_nodes        = bool
    enable_secure_boot           = bool
    enable_integrity_monitoring  = bool
  })
  default = {
    machine_type   = "e2-medium"
    disk_size_gb   = 100
    disk_type      = "pd-standard"
    image_type     = "COS_CONTAINERD"
    preemptible    = false
    spot           = false
    service_account = null
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels         = {}
    tags           = []
    taint          = []
    metadata       = {}
    workload_metadata_mode      = "GKE_METADATA"
    enable_shielded_nodes       = true
    enable_secure_boot          = false
    enable_integrity_monitoring = true
  }
}

variable "management" {
  description = "Node pool management configuration"
  type = object({
    auto_repair  = bool
    auto_upgrade = bool
  })
  default = {
    auto_repair  = true
    auto_upgrade = true
  }
}

variable "upgrade_settings" {
  description = "Upgrade settings for the node pool"
  type = object({
    max_surge       = number
    max_unavailable = number
  })
  default = {
    max_surge       = 1
    max_unavailable = 0
  }
}