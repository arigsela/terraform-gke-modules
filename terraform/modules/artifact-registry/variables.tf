variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "location" {
  description = "The location of the repository"
  type        = string
  default     = "us-central1"
}

variable "repository_id" {
  description = "The ID of the repository"
  type        = string
}

variable "description" {
  description = "The description of the repository"
  type        = string
  default     = "Docker repository for containerized applications"
}

variable "format" {
  description = "The format of packages in the repository"
  type        = string
  default     = "DOCKER"
  validation {
    condition = contains([
      "DOCKER", "MAVEN", "NPM", "APT", "YUM", "PYTHON", "KUBEFLOW_PIPELINES"
    ], var.format)
    error_message = "Repository format must be one of: DOCKER, MAVEN, NPM, APT, YUM, PYTHON, KUBEFLOW_PIPELINES."
  }
}

variable "labels" {
  description = "Labels to apply to the repository"
  type        = map(string)
  default     = {}
}

variable "docker_config" {
  description = "Docker-specific configuration"
  type = object({
    immutable_tags = bool
  })
  default = {
    immutable_tags = false
  }
}

variable "maven_config" {
  description = "Maven-specific configuration"
  type = object({
    allow_snapshot_overwrites = bool
    version_policy           = string
  })
  default = {
    allow_snapshot_overwrites = true
    version_policy           = "VERSION_POLICY_UNSPECIFIED"
  }
}

variable "cleanup_policies" {
  description = "Cleanup policies for the repository"
  type = list(object({
    id     = string
    action = string
    condition = object({
      tag_state             = string
      tag_prefixes         = list(string)
      version_name_prefixes = list(string)
      package_name_prefixes = list(string)
      older_than           = string
    })
  }))
  default = [
    {
      id     = "delete-old-images"
      action = "DELETE"
      condition = {
        tag_state             = "UNTAGGED"
        tag_prefixes         = []
        version_name_prefixes = []
        package_name_prefixes = []
        older_than           = "2592000s" # 30 days
      }
    }
  ]
}

variable "reader_members" {
  description = "List of members to grant reader access"
  type        = list(string)
  default     = []
}

variable "writer_members" {
  description = "List of members to grant writer access"
  type        = list(string)
  default     = []
}