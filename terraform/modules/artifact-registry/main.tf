# Artifact Registry Repository
resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = var.format
  
  # Docker configuration
  dynamic "docker_config" {
    for_each = var.format == "DOCKER" ? [1] : []
    content {
      immutable_tags = var.docker_config.immutable_tags
    }
  }

  # Maven configuration
  dynamic "maven_config" {
    for_each = var.format == "MAVEN" ? [1] : []
    content {
      allow_snapshot_overwrites = var.maven_config.allow_snapshot_overwrites
      version_policy           = var.maven_config.version_policy
    }
  }

  labels = var.labels

  # Cleanup policies
  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      id     = cleanup_policies.value.id
      action = cleanup_policies.value.action
      
      condition {
        tag_state             = cleanup_policies.value.condition.tag_state
        tag_prefixes         = cleanup_policies.value.condition.tag_prefixes
        version_name_prefixes = cleanup_policies.value.condition.version_name_prefixes
        package_name_prefixes = cleanup_policies.value.condition.package_name_prefixes
        older_than           = cleanup_policies.value.condition.older_than
      }
    }
  }
}

# IAM bindings for the repository
resource "google_artifact_registry_repository_iam_binding" "readers" {
  count = length(var.reader_members) > 0 ? 1 : 0
  
  project    = var.project_id
  location   = google_artifact_registry_repository.repo.location
  repository = google_artifact_registry_repository.repo.name
  role       = "roles/artifactregistry.reader"
  members    = var.reader_members
}

resource "google_artifact_registry_repository_iam_binding" "writers" {
  count = length(var.writer_members) > 0 ? 1 : 0
  
  project    = var.project_id
  location   = google_artifact_registry_repository.repo.location
  repository = google_artifact_registry_repository.repo.name
  role       = "roles/artifactregistry.writer"  
  members    = var.writer_members
}