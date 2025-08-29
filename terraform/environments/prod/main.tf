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

# Additional providers for Kubernetes resources
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

# Terraform backend configuration
terraform {
  backend "gcs" {
    bucket      = "chores-tracker-terraform-state-chores-tracker-prod"
    prefix      = "terraform/prod"
    credentials = "../../terraform-key.json"
  }
}

# VPC and networking
module "vpc" {
  source = "../../modules/networking"
  
  project_id   = var.project_id
  region       = var.region
  network_name = "gke-vpc-prod"
  
  subnets = [{
    subnet_name   = "gke-subnet-prod"
    subnet_ip     = "10.0.1.0/24"
    subnet_region = var.region
  }]
  
  secondary_ranges = {
    "gke-subnet-prod" = [
      {
        range_name    = "gke-pods-prod"
        ip_cidr_range = "10.1.0.0/16"
      },
      {
        range_name    = "gke-services-prod"
        ip_cidr_range = "10.2.0.0/16"
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
  workload_identity_sa_name         = "chores-tracker-wi-prod"
  workload_identity_sa_display_name = "Chores Tracker Workload Identity - Production"
  kubernetes_namespace              = "chores-tracker"
  kubernetes_service_account        = "chores-tracker"
  
  workload_identity_roles = [
    "roles/secretmanager.secretAccessor",
    "roles/artifactregistry.reader",
  ]
  
  # GKE Node SA
  create_gke_node_sa        = true
  gke_node_sa_name         = "gke-node-sa-prod"
  gke_node_sa_display_name = "GKE Node Service Account - Production"
  
  gke_node_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader"
  ]
}

# GKE Cluster
module "gke" {
  source = "../../modules/gke-cluster"
  
  project_id     = var.project_id
  name           = "chores-tracker-cluster-prod"
  location       = "us-central1-a"  # Use zonal for cost savings
  # node_locations = var.node_locations  # Comment out for zonal cluster
  
  network    = "projects/${var.project_id}/global/networks/gke-vpc-prod"
  subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/gke-subnet-prod"
  
  ip_range_pods     = "gke-pods-prod"
  ip_range_services = "gke-services-prod"
  
  # Workload Identity
  workload_identity_config = {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1
  
  # Disable cluster autoscaling to prevent auto-provisioning
  cluster_autoscaling = {
    enabled = false
    resource_limits = []
  }
  
  # Features
  network_policy_enabled                = true
  http_load_balancing_disabled          = true  # Using NGINX instead
  horizontal_pod_autoscaling_disabled   = false
  
  # Release channel
  release_channel = "REGULAR"
  
  # Service account for cluster nodes
  service_account = module.iam.gke_node_service_account_email
  
  oauth_scopes = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]
}

# System Node Pool
module "system_node_pool" {
  source = "../../modules/gke-node-pool"
  
  project_id = var.project_id
  name       = "system-pool-prod"
  cluster    = module.gke.name
  location   = module.gke.location
  
  node_count = 1
  
  autoscaling = {
    enabled        = true
    min_node_count = 1
    max_node_count = 2
  }
  
  node_config = {
    machine_type   = "e2-small"
    disk_size_gb   = 50
    disk_type      = "pd-standard"
    image_type     = "COS_CONTAINERD"
    preemptible    = false
    spot           = false
    service_account = module.iam.gke_node_service_account_email
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    labels = {
      pool        = "system"
      environment = "production"
    }
    
    tags = ["gke-node", "system-pool"]
    
    taint = [{
      key    = "system"
      value  = "true"
      effect = "NO_SCHEDULE"
    }]
    
    metadata                     = {}
    workload_metadata_mode       = "GKE_METADATA"
    enable_shielded_nodes        = true
    enable_secure_boot           = true
    enable_integrity_monitoring  = true
  }
}

# Application Node Pool (Spot Instances)
module "app_node_pool" {
  source = "../../modules/gke-node-pool"
  
  project_id = var.project_id
  name       = "app-spot-pool-prod"
  cluster    = module.gke.name
  location   = module.gke.location
  
  node_count = 1
  
  autoscaling = {
    enabled        = true
    min_node_count = 1
    max_node_count = 2
  }
  
  node_config = {
    machine_type   = "e2-medium"
    disk_size_gb   = 50
    disk_type      = "pd-standard"
    image_type     = "COS_CONTAINERD"
    preemptible    = false
    spot           = true  # Enable spot instances for cost savings
    service_account = module.iam.gke_node_service_account_email
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    labels = {
      pool        = "application"
      type        = "spot"
      environment = "production"
    }
    
    tags = ["gke-node", "app-pool"]
    
    taint = []
    
    metadata                     = {}
    workload_metadata_mode       = "GKE_METADATA"
    enable_shielded_nodes        = true
    enable_secure_boot           = false
    enable_integrity_monitoring  = true
  }
}

# Artifact Registry
module "artifact_registry" {
  source = "../../modules/artifact-registry"
  
  project_id    = var.project_id
  location      = var.region
  repository_id = "chores-tracker-prod"
  description   = "Docker repository for chores tracker applications - Production"
  format        = "DOCKER"
  
  labels = {
    environment = "production"
    team        = "infrastructure"
  }
  
  # IAM bindings
  writer_members = [
    "serviceAccount:${module.iam.workload_identity_service_account_email}",
    "serviceAccount:terraform-sa@${var.project_id}.iam.gserviceaccount.com"
  ]
  
  reader_members = [
    "serviceAccount:${module.iam.gke_node_service_account_email}"
  ]
}

# Static IP for Load Balancer
resource "google_compute_global_address" "ingress_ip" {
  name    = "chores-tracker-ip-prod"
  project = var.project_id
}

# NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.3"
  namespace  = "ingress-nginx"
  timeout    = 600

  create_namespace = true

  values = [
    yamlencode({
      controller = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "cloud.google.com/load-balancer-type" = "External"
          }
        }
        
        nodeSelector = {
          pool = "system"
        }
        
        tolerations = [{
          key    = "system"
          value  = "true"
          effect = "NoSchedule"
        }]
        
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
      }
    })
  ]

  depends_on = [
    module.system_node_pool,
    google_compute_global_address.ingress_ip
  ]
}

# ArgoCD Installation
module "argocd" {
  source = "../../modules/argocd"
  
  project_id = var.project_id
  hostname   = "argocd.chores.arigsela.com"
  
  # Deploy to system nodes with tolerations
  node_selector = {
    pool = "system"
  }
  
  tolerations = [{
    key      = "system"
    operator = "Equal"
    value    = "true"
    effect   = "NoSchedule"
  }]
  
  # Workload Identity integration
  workload_identity_enabled         = true
  workload_identity_service_account = module.iam.workload_identity_service_account_email
  
  # ApplicationSet configuration
  enable_applicationset = true
  repository_url       = "https://github.com/arigsela/kubernetes"
  applications_path    = "appset-base-apps"
  
  depends_on = [
    module.gke,
    module.system_node_pool,
    google_compute_global_address.ingress_ip,
    helm_release.nginx_ingress
  ]
}