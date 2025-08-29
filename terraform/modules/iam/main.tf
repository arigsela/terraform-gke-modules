# Service Account for Workload Identity
resource "google_service_account" "workload_identity" {
  count        = var.create_workload_identity_sa ? 1 : 0
  account_id   = var.workload_identity_sa_name
  display_name = var.workload_identity_sa_display_name
  project      = var.project_id
  description  = "Service account for workload identity in GKE"
}

# Service Account for GKE Nodes
resource "google_service_account" "gke_node_sa" {
  count        = var.create_gke_node_sa ? 1 : 0
  account_id   = var.gke_node_sa_name
  display_name = var.gke_node_sa_display_name
  project      = var.project_id
  description  = "Service account for GKE node pools"
}

# Workload Identity binding
resource "google_service_account_iam_binding" "workload_identity_binding" {
  count              = var.create_workload_identity_sa ? 1 : 0
  service_account_id = google_service_account.workload_identity[0].name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.kubernetes_namespace}/${var.kubernetes_service_account}]"
  ]
}

# IAM roles for workload identity service account
resource "google_project_iam_member" "workload_identity_roles" {
  for_each = var.create_workload_identity_sa ? toset(var.workload_identity_roles) : toset([])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.workload_identity[0].email}"
}

# IAM roles for GKE node service account
resource "google_project_iam_member" "gke_node_roles" {
  for_each = var.create_gke_node_sa ? toset(var.gke_node_roles) : toset([])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_node_sa[0].email}"
}

# Custom IAM roles (if needed)
resource "google_project_iam_custom_role" "custom_roles" {
  for_each = var.custom_roles
  
  role_id     = each.key
  title       = each.value.title
  description = each.value.description
  project     = var.project_id
  permissions = each.value.permissions
  stage       = each.value.stage
}

# Additional project-level IAM bindings
resource "google_project_iam_binding" "project_bindings" {
  for_each = var.project_iam_bindings
  
  project = var.project_id
  role    = each.key
  members = each.value
}

# Service account keys (if needed for external access)
resource "google_service_account_key" "workload_identity_key" {
  count              = var.create_workload_identity_key ? 1 : 0
  service_account_id = google_service_account.workload_identity[0].name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_service_account_key" "gke_node_key" {
  count              = var.create_gke_node_key ? 1 : 0
  service_account_id = google_service_account.gke_node_sa[0].name
  public_key_type    = "TYPE_X509_PEM_FILE"
}