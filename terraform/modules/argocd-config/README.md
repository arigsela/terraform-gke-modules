# ArgoCD Configuration Module

This Terraform module configures ArgoCD with Projects, Repositories, and ApplicationSets to implement an automated app-of-apps pattern using Git directory structure.

## Features

- **ArgoCD Project**: Creates a production project with appropriate permissions
- **Repository Integration**: Configures Git repository for automatic application discovery
- **ApplicationSet**: Implements Git directory generator for automatic application deployment
- **Namespace Mapping**: Each folder in the repository becomes a separate namespace

## Usage

```hcl
module "argocd_config" {
  source = "../../modules/argocd-config"
  
  argocd_namespace   = "argocd"
  repository_url     = "https://github.com/arigsela/kubernetes"
  applications_path  = "appset-base-apps"
  project_name      = "production"
  
  sync_policy = {
    automated = {
      prune     = true
      self_heal = true
    }
    sync_options = ["CreateNamespace=true"]
  }
}
```

## Repository Structure

The module expects the following repository structure:

```
repository-root/
└── appset-base-apps/
    ├── app1-prod/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── configmap.yaml
    ├── app2-staging/
    │   ├── kustomization.yaml
    │   └── base/
    │       └── ...
    └── vault-prod/
        ├── namespace.yaml
        ├── deployment.yaml
        └── service.yaml
```

## How It Works

1. **ApplicationSet Discovery**: Scans `appset-base-apps/*` for directories
2. **Application Generation**: Creates an ArgoCD Application for each directory found
3. **Namespace Mapping**: Uses folder name as the target namespace (e.g., `vault-prod` → namespace `vault-prod`)
4. **Automatic Sync**: Deployed applications automatically sync when repository changes

## Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `argocd_namespace` | Namespace where ArgoCD is deployed | `string` | `"argocd"` |
| `repository_url` | Git repository URL containing applications | `string` | `"https://github.com/arigsela/kubernetes"` |
| `applications_path` | Base path in repository containing applications | `string` | `"appset-base-apps"` |
| `project_name` | ArgoCD project name | `string` | `"production"` |
| `sync_policy` | Application sync policy configuration | `object` | See variables.tf |
| `destination_server` | Kubernetes cluster server URL | `string` | `"https://kubernetes.default.svc"` |
| `target_revision` | Git branch/tag to track | `string` | `"HEAD"` |

## Outputs

| Output | Description |
|--------|-------------|
| `project_name` | ArgoCD project name |
| `repository_url` | Configured repository URL |
| `applicationset_name` | ApplicationSet name |
| `applications_path` | Base path for applications in repository |

## Requirements

- Terraform >= 1.0
- Kubernetes provider >= 2.23.0
- ArgoCD already deployed in the cluster
- Git repository with appropriate structure

## Adding New Applications

To add a new application:

1. Create a new directory under `appset-base-apps/` in your Git repository
2. Add Kubernetes manifests (YAML files) or Kustomize/Helm configuration
3. Commit and push to the repository
4. ApplicationSet will automatically detect the new directory and create an ArgoCD Application
5. The application will be deployed to a namespace matching the directory name

## Example Application Structure

### Simple Kubernetes Manifests
```
appset-base-apps/my-app/
├── namespace.yaml
├── deployment.yaml
├── service.yaml
└── configmap.yaml
```

### Kustomize Application
```
appset-base-apps/my-app/
├── kustomization.yaml
├── deployment.yaml
├── service.yaml
└── overlays/
    └── production/
        ├── kustomization.yaml
        └── patch.yaml
```

### Helm Chart
```
appset-base-apps/my-app/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
└── charts/
```

## Troubleshooting

1. **ApplicationSet not creating Applications**: Check if directories exist under the specified path
2. **Application sync failures**: Verify Kubernetes manifests are valid
3. **Permission issues**: Ensure ArgoCD has necessary RBAC permissions
4. **Repository access**: Verify repository URL is accessible and credentials are correct (if private)

## Security Considerations

- Repository is configured as public (no authentication required)
- Project allows all resources in all namespaces (suitable for production environments with proper GitOps practices)
- Applications are automatically synced with self-healing enabled
- Each application is isolated in its own namespace