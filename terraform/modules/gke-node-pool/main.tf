# GKE Node Pool
resource "google_container_node_pool" "pool" {
  name     = var.name
  project  = var.project_id
  location = var.location
  cluster  = var.cluster

  # Node count
  node_count = var.autoscaling.enabled ? null : var.node_count

  # Autoscaling
  dynamic "autoscaling" {
    for_each = var.autoscaling.enabled ? [1] : []
    content {
      min_node_count = var.autoscaling.min_node_count
      max_node_count = var.autoscaling.max_node_count
    }
  }

  # Node configuration
  node_config {
    preemptible  = var.node_config.preemptible
    spot         = var.node_config.spot
    machine_type = var.node_config.machine_type
    disk_size_gb = var.node_config.disk_size_gb
    disk_type    = var.node_config.disk_type
    image_type   = var.node_config.image_type

    # Service account
    service_account = var.node_config.service_account
    oauth_scopes    = var.node_config.oauth_scopes

    # Labels
    labels = var.node_config.labels

    # Tags
    tags = var.node_config.tags

    # Taints
    dynamic "taint" {
      for_each = var.node_config.taint
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # Metadata
    metadata = merge(
      var.node_config.metadata,
      {
        "disable-legacy-endpoints" = "true"
      }
    )

    # Workload metadata config
    workload_metadata_config {
      mode = var.node_config.workload_metadata_mode
    }

    # Shielded instance config
    dynamic "shielded_instance_config" {
      for_each = var.node_config.enable_shielded_nodes ? [1] : []
      content {
        enable_secure_boot          = var.node_config.enable_secure_boot
        enable_integrity_monitoring = var.node_config.enable_integrity_monitoring
      }
    }
  }

  # Management
  management {
    auto_repair  = var.management.auto_repair
    auto_upgrade = var.management.auto_upgrade
  }

  # Upgrade settings
  dynamic "upgrade_settings" {
    for_each = var.upgrade_settings != null ? [1] : []
    content {
      max_surge       = var.upgrade_settings.max_surge
      max_unavailable = var.upgrade_settings.max_unavailable
    }
  }

  # Timeouts
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  # Lifecycle
  lifecycle {
    create_before_destroy = true
  }
}