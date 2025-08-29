# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.name
  project  = var.project_id
  location = var.location
  
  # Node locations for cluster - only set if provided
  node_locations = length(var.node_locations) > 0 ? var.node_locations : null

  # Remove default node pool
  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = var.initial_node_count

  # Networking
  network    = var.network
  subnetwork = var.subnetwork

  # IP allocation for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods
    services_secondary_range_name = var.ip_range_services
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = var.workload_identity_config.workload_pool
  }

  # Network policy
  network_policy {
    enabled = var.network_policy_enabled
  }

  # Addons configuration
  addons_config {
    http_load_balancing {
      disabled = var.http_load_balancing_disabled
    }

    horizontal_pod_autoscaling {
      disabled = var.horizontal_pod_autoscaling_disabled
    }

    network_policy_config {
      disabled = !var.network_policy_enabled
    }
  }

  # Cluster autoscaling
  dynamic "cluster_autoscaling" {
    for_each = var.cluster_autoscaling.enabled ? [1] : []
    content {
      enabled = true
      dynamic "resource_limits" {
        for_each = var.cluster_autoscaling.resource_limits
        content {
          resource_type = resource_limits.value.resource_type
          minimum       = resource_limits.value.minimum
          maximum       = resource_limits.value.maximum
        }
      }
    }
  }

  # Release channel
  release_channel {
    channel = var.release_channel
  }

  # Master auth configuration
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Private cluster configuration
  dynamic "private_cluster_config" {
    for_each = var.private_cluster ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }
  }

  # Master authorized networks
  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  # Maintenance policy
  dynamic "maintenance_policy" {
    for_each = var.maintenance_policy != null ? [1] : []
    content {
      dynamic "daily_maintenance_window" {
        for_each = var.maintenance_policy.daily_maintenance_window != null ? [1] : []
        content {
          start_time = var.maintenance_policy.daily_maintenance_window.start_time
        }
      }
    }
  }

  # Node configuration
  node_config {
    service_account = var.service_account
    oauth_scopes    = var.oauth_scopes
    
    # Match current cluster configuration
    machine_type   = "e2-medium"
    disk_size_gb   = 50
    disk_type      = "pd-standard"
    image_type     = "COS_CONTAINERD"
    spot           = true
    
    labels = {
      environment = "production"
      pool        = "application"
      type        = "spot"
    }
    
    tags = ["gke-node", "app-pool"]
    
    metadata = {
      "disable-legacy-endpoints" = "true"
    }
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    shielded_instance_config {
      enable_integrity_monitoring = true
    }
  }

  # Lifecycle
  lifecycle {
    ignore_changes = [node_pool]
  }

  # Timeouts
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}