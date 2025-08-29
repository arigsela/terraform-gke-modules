variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "The name of the cluster"
  type        = string
}

variable "location" {
  description = "The location (region or zone) for the cluster"
  type        = string
}

variable "node_locations" {
  description = "List of zones for cluster nodes"
  type        = list(string)
  default     = []
}

variable "network" {
  description = "The VPC network to host the cluster in"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
  type        = string
}

variable "ip_range_pods" {
  description = "The secondary range for pods"
  type        = string
}

variable "ip_range_services" {
  description = "The secondary range for services"
  type        = string
}

variable "remove_default_node_pool" {
  description = "Remove default node pool while cluster creation"
  type        = bool
  default     = true
}

variable "initial_node_count" {
  description = "The number of nodes to create in this cluster"
  type        = number
  default     = 1
}

variable "workload_identity_config" {
  description = "Workload identity configuration"
  type = object({
    workload_pool = string
  })
  default = {
    workload_pool = null
  }
}

variable "network_policy_enabled" {
  description = "Enable network policy addon"
  type        = bool
  default     = true
}

variable "http_load_balancing_disabled" {
  description = "Disable HTTP load balancing addon"
  type        = bool
  default     = false
}

variable "horizontal_pod_autoscaling_disabled" {
  description = "Disable horizontal pod autoscaling addon"
  type        = bool
  default     = false
}

variable "cluster_autoscaling" {
  description = "Cluster autoscaling configuration"
  type = object({
    enabled = bool
    resource_limits = list(object({
      resource_type = string
      minimum       = number
      maximum       = number
    }))
  })
  default = {
    enabled = false
    resource_limits = []
  }
}

variable "release_channel" {
  description = "Release channel configuration"
  type        = string
  default     = "REGULAR"
}

variable "private_cluster" {
  description = "Enable private cluster"
  type        = bool
  default     = false
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation for the master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "List of master authorized networks"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "maintenance_policy" {
  description = "Maintenance policy configuration"
  type = object({
    daily_maintenance_window = object({
      start_time = string
    })
  })
  default = null
}

variable "service_account" {
  description = "Service account for nodes"
  type        = string
  default     = null
}

variable "oauth_scopes" {
  description = "OAuth scopes for nodes"
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]
}