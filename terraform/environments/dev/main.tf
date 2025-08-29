# Provider configuration
provider "google" {
  credentials = file("../../terraform-key.json")
  project     = var.project_id
  region      = var.region
}

provider "google-beta" {
  credentials = file("../../terraform-key.json")
  project     = var.project_id
  region      = var.region
}

# Terraform backend configuration
terraform {
  backend "gcs" {
    bucket      = "chores-tracker-terraform-state-chores-tracker-prod"
    prefix      = "terraform/dev"
    credentials = "../../terraform-key.json"
  }
}

# VPC and networking
module "vpc" {
  source = "../../modules/networking"
  
  project_id   = var.project_id
  region       = var.region
  network_name = "gke-vpc-dev"
  
  subnets = [{
    subnet_name   = "gke-subnet-dev"
    subnet_ip     = "10.10.1.0/24"
    subnet_region = var.region
  }]
  
  secondary_ranges = {
    "gke-subnet-dev" = [
      {
        range_name    = "gke-pods-dev"
        ip_cidr_range = "10.11.0.0/16"
      },
      {
        range_name    = "gke-services-dev"
        ip_cidr_range = "10.12.0.0/16"
      }
    ]
  }
}

# IAM Service Accounts
module "iam" {
  source = "../../modules/iam"
  
  project_id = var.project_id
  
  # Workload Identity SA
  create_workload_identity_sa        = true
  workload_identity_sa_name         = "chores-tracker-wi-dev"
  workload_identity_sa_display_name = "Chores Tracker Workload Identity - Development"
  kubernetes_namespace              = "chores-tracker-dev"
  kubernetes_service_account        = "chores-tracker"
  
  workload_identity_roles = [
    "roles/secretmanager.secretAccessor",
    "roles/artifactregistry.reader",
  ]
  
  # GKE Node SA
  create_gke_node_sa        = true
  gke_node_sa_name         = "gke-node-sa-dev"
  gke_node_sa_display_name = "GKE Node Service Account - Development"
}

# GKE Cluster (smaller for dev)
module "gke" {
  source = "../../modules/gke-cluster"
  
  project_id     = var.project_id
  name           = "chores-tracker-cluster-dev"
  location       = var.zone  # Zonal for dev to save costs
  
  network    = module.vpc.network_name
  subnetwork = module.vpc.subnets["gke-subnet-dev"].name
  
  ip_range_pods     = "gke-pods-dev"
  ip_range_services = "gke-services-dev"
  
  # Workload Identity
  workload_identity_config = {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  remove_default_node_pool = true
  initial_node_count       = 1
  
  # Simpler autoscaling for dev
  cluster_autoscaling = {
    enabled = true
    resource_limits = [
      {
        resource_type = "cpu"
        minimum       = 1
        maximum       = 4
      },
      {
        resource_type = "memory"
        minimum       = 4
        maximum       = 16
      }
    ]
  }
  
  service_account = module.iam.gke_node_service_account_email
}

# Single node pool for dev (spot instances)
module "dev_node_pool" {
  source = "../../modules/gke-node-pool"
  
  project_id = var.project_id
  name       = "dev-pool"
  cluster    = module.gke.name
  location   = module.gke.location
  
  node_count = 1
  
  autoscaling = {
    enabled        = true
    min_node_count = 1
    max_node_count = 3
  }
  
  node_config = {
    machine_type   = "e2-small"  # Smaller for dev
    disk_size_gb   = 50
    disk_type      = "pd-standard"
    image_type     = "COS_CONTAINERD"
    preemptible    = false
    spot           = true  # Spot instances for cost savings
    service_account = module.iam.gke_node_service_account_email
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    labels = {
      environment = "development"
    }
    
    tags = ["gke-node", "dev-pool"]
    taint = []
    metadata = {}
    workload_metadata_mode = "GKE_METADATA"
    enable_shielded_nodes = true
    enable_secure_boot = false
    enable_integrity_monitoring = true
  }
}

# Artifact Registry for dev
module "artifact_registry" {
  source = "../../modules/artifact-registry"
  
  project_id    = var.project_id
  location      = var.region
  repository_id = "chores-tracker-dev"
  description   = "Docker repository for chores tracker applications - Development"
  format        = "DOCKER"
  
  labels = {
    environment = "development"
  }
  
  writer_members = [
    "serviceAccount:${module.iam.workload_identity_service_account_email}",
    "serviceAccount:terraform-sa@${var.project_id}.iam.gserviceaccount.com"
  ]
  
  reader_members = [
    "serviceAccount:${module.iam.gke_node_service_account_email}"
  ]
}