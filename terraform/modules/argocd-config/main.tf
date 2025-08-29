# ArgoCD Project
resource "kubernetes_manifest" "argocd_project" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = var.project_name
      namespace = var.argocd_namespace
      labels = {
        "app.kubernetes.io/part-of" = "argocd"
      }
    }
    spec = {
      description = "Production applications managed by ApplicationSet"
      
      # Source repositories that applications within this project can pull manifests from
      sourceRepos = [
        var.repository_url
      ]
      
      # Destinations that applications within this project can deploy to
      destinations = [
        {
          namespace = "*"
          server    = var.destination_server
        }
      ]
      
      # Cluster-scoped resources which may be created
      clusterResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
      
      # Namespace-scoped resources which may be created
      namespaceResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
      
      # Roles which provide API access
      roles = [
        {
          name = "admin"
          policies = [
            "p, proj:${var.project_name}:admin, applications, *, ${var.project_name}/*, allow",
            "p, proj:${var.project_name}:admin, repositories, *, *, allow",
            "p, proj:${var.project_name}:admin, logs, get, ${var.project_name}/*, allow",
            "p, proj:${var.project_name}:admin, exec, create, ${var.project_name}/*, allow"
          ]
        }
      ]
    }
  }
}

# ArgoCD Repository
resource "kubernetes_manifest" "argocd_repository" {
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "repo-${replace(replace(var.repository_url, "https://", ""), "/", "-")}"
      namespace = var.argocd_namespace
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
        "app.kubernetes.io/part-of"      = "argocd"
      }
    }
    type = "Opaque"
    data = {
      type    = base64encode("git")
      url     = base64encode(var.repository_url)
      project = base64encode(var.project_name)
    }
  }
}

# ApplicationSet
resource "kubernetes_manifest" "applicationset" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "ApplicationSet"
    metadata = {
      name      = "${var.project_name}-apps"
      namespace = var.argocd_namespace
      labels = {
        "app.kubernetes.io/part-of" = "argocd"
      }
    }
    spec = {
      generators = [
        {
          git = {
            repoURL  = var.repository_url
            revision = var.target_revision
            directories = [
              {
                path = "${var.applications_path}/*"
              }
            ]
          }
        }
      ]
      template = {
        metadata = {
          name = "{{path.basename}}"
          labels = {
            "app.kubernetes.io/part-of" = "argocd"
            "managed-by"                = "applicationset"
          }
        }
        spec = {
          project = var.project_name
          source = {
            repoURL        = var.repository_url
            targetRevision = var.target_revision
            path           = "{{path}}"
          }
          destination = {
            server    = var.destination_server
            namespace = "{{path.basename}}"
          }
          syncPolicy = {
            automated = {
              prune    = var.sync_policy.automated.prune
              selfHeal = var.sync_policy.automated.self_heal
            }
            syncOptions = var.sync_policy.sync_options
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_manifest.argocd_project,
    kubernetes_manifest.argocd_repository
  ]
}