# ArgoCD Namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/name" = "argocd"
      "app.kubernetes.io/instance" = "argocd"
    }
  }
}

# ArgoCD Helm Release
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.11"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  timeout    = 900

  values = [
    templatefile("${path.module}/values.yaml", {
      hostname = var.hostname
      node_selector = var.node_selector
      tolerations = var.tolerations
      ingress_class = var.ingress_class
      cert_issuer = var.cert_issuer
      workload_identity = var.workload_identity_enabled
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Service Account for Workload Identity
resource "kubernetes_service_account" "argocd_application_controller" {
  count = var.workload_identity_enabled ? 1 : 0

  metadata {
    name      = "argocd-application-controller"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = var.workload_identity_service_account
    }
  }
}

resource "kubernetes_service_account" "argocd_server" {
  count = var.workload_identity_enabled ? 1 : 0

  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = var.workload_identity_service_account
    }
  }
}

# ArgoCD Configuration (Projects, Repositories, ApplicationSets)
module "argocd_config" {
  count  = var.enable_applicationset ? 1 : 0
  source = "../argocd-config"

  argocd_namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository_url    = var.repository_url
  applications_path = var.applications_path
  project_name     = "production"

  depends_on = [
    helm_release.argocd
  ]
}