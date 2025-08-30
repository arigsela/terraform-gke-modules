# Terraform GKE Modules

A comprehensive Terraform infrastructure-as-code project for deploying and managing cost-optimized Google Kubernetes Engine (GKE) clusters with GitOps capabilities.

## 🏗️ Overview

This project provides a complete GKE infrastructure stack designed for the "Chores Tracker" application, with a focus on cost optimization while maintaining production reliability. It includes automated deployment pipelines using ArgoCD and supports both production and development environments.

### Key Features

- **Cost-Optimized Architecture**: Utilizes spot instances and smart resource allocation to minimize costs
- **GitOps Integration**: Full ArgoCD setup with ApplicationSet for automated deployments
- **Multi-Environment Support**: Separate production and development configurations
- **Security-First**: Workload Identity, Network Policies, and Shielded Nodes
- **Modular Design**: Reusable Terraform modules for different infrastructure components

## 📊 Architecture

### Infrastructure Components

```
┌─────────────────────────────────────────────────────────────────┐
│                        GKE Cluster                              │
├─────────────────────────────────────────────────────────────────┤
│  System Node Pool (e2-small)     │  App Node Pool (e2-medium)   │
│  - ArgoCD                        │  - Chores Tracker App        │
│  - NGINX Ingress                 │  - Future Applications       │
│  - DNS/Monitoring                │  - Spot Instances (80% off)  │
└─────────────────────────────────────────────────────────────────┘
│
├── VPC Networking (10.0.1.0/24)
├── Artifact Registry (Docker Images)
├── IAM & Workload Identity
└── Load Balancer + SSL/TLS
```

### Cost Optimization Strategy

- **Spot Instances**: 60-80% cost savings on application workloads
- **Single Load Balancer**: NGINX Ingress instead of multiple GCP load balancers
- **Zonal Cluster**: Production uses single-zone deployment for cost benefits
- **Auto-scaling**: Dynamic scaling from 1-5 nodes based on demand
- **Estimated Cost**: $56-86/month for production environment

## 🗂️ Project Structure

```
terraform/
├── bootstrap/                 # Terraform backend setup
├── environments/
│   ├── prod/                 # Production environment
│   └── dev/                  # Development environment
├── modules/                  # Reusable Terraform modules
│   ├── networking/           # VPC, subnets, firewall rules
│   ├── gke-cluster/          # GKE cluster configuration
│   ├── gke-node-pool/        # Node pool management
│   ├── iam/                  # Service accounts and permissions
│   ├── artifact-registry/    # Container image registry
│   ├── argocd/               # ArgoCD installation
│   └── argocd-config/        # ArgoCD ApplicationSet setup
├── scripts/                  # Deployment and management scripts
└── docs/                     # Implementation documentation
```

## 📦 Terraform Modules

### Core Infrastructure Modules

#### `networking`
- VPC network with custom subnets
- Secondary IP ranges for GKE pods and services
- Cloud NAT and firewall rules
- Multi-subnet support

#### `gke-cluster`
- GKE cluster with Workload Identity
- Network Policy and auto-scaling support
- Release channel management
- Private cluster capabilities

#### `gke-node-pool`
- Multiple node pool configurations
- Spot instance and preemptible VM support
- Auto-scaling and upgrade management
- Security features (Shielded Nodes)

#### `iam`
- Workload Identity service accounts
- GKE node service accounts
- Custom IAM roles and bindings
- Minimal privilege access

#### `artifact-registry`
- Docker/Maven repository management
- IAM access control
- Image lifecycle policies
- Multi-format support

### GitOps Modules

#### `argocd`
- Complete ArgoCD installation via Helm
- SSL/TLS ingress configuration
- Resource optimization
- Workload Identity integration

#### `argocd-config`
- ArgoCD projects and repositories
- ApplicationSet with Git directory generator
- Automated application discovery
- Self-healing deployment policies

## 🚀 Quick Start

### Prerequisites

- Google Cloud Platform account with billing enabled
- Terraform >= 1.0
- `gcloud` CLI configured
- Service account key with necessary permissions

### 1. Clone Repository

```bash
git clone <repository-url>
cd terraform-gke-modules
```

### 2. Setup Environment Variables

```bash
export TF_VAR_project_id="your-project-id"
export TF_VAR_region="us-central1"
```

### 3. Initialize Terraform Backend

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

### 4. Deploy Infrastructure

```bash
cd ../environments/prod  # or dev
terraform init
terraform plan
terraform apply
```

### 5. Configure kubectl

```bash
gcloud container clusters get-credentials chores-tracker-cluster-prod \
  --zone us-central1-a --project your-project-id
```

## 🛠️ Environment Configuration

### Production Environment

- **Cluster**: `chores-tracker-cluster-prod`
- **Location**: `us-central1-a` (zonal for cost savings)
- **Node Pools**: 
  - System: 1-3 e2-small instances (regular)
  - Application: 1-2 e2-medium instances (spot)
- **Domain**: `chores.arigsela.com`

### Development Environment

- **Cluster**: `chores-tracker-cluster-dev`
- **Location**: `us-central1-a`
- **Node Pools**: 
  - Dev: 1-3 e2-small instances (spot)
- **Simplified configuration** for testing

## 🔄 GitOps Integration

### ArgoCD ApplicationSet

The project includes a configured ApplicationSet that:

- **Repository**: `https://github.com/arigsela/kubernetes`
- **Path**: `appset-base-apps/`
- **Pattern**: Each subdirectory becomes a namespace
- **Example**: `appset-base-apps/vault-prod` → namespace `vault-prod`

### Application Discovery

Applications are automatically discovered and deployed when:
1. A new directory is created in `appset-base-apps/`
2. The directory contains valid Kubernetes manifests
3. ArgoCD syncs every 3 minutes (configurable)

## 🔧 Management Scripts

### `scripts/setup.sh`
Complete infrastructure deployment script with error handling and validation.

### `scripts/deploy.sh`
Application deployment script for kubectl and Helm operations.

### `scripts/migrate-images.sh`
Container image migration utility for moving from ECR to Artifact Registry.

## 🔐 Security Features

- **Workload Identity**: Secure service account binding
- **Network Policies**: Pod-to-pod communication control
- **Shielded Nodes**: Protection against rootkits
- **Private Networking**: Nodes without public IPs
- **RBAC Integration**: Role-based access control

## 💰 Cost Monitoring

### Monthly Estimates (Production)

| Component | Cost Range | Notes |
|-----------|------------|-------|
| GKE Cluster | $0 | Free tier for zonal cluster |
| System Nodes (e2-small) | $12-37 | 1-3 instances |
| App Nodes (e2-medium) | $6-12 | 1-2 spot instances |
| Load Balancer | $18 | Single external LB |
| Artifact Registry | $5-10 | Storage and bandwidth |
| **Total** | **$41-77** | Varies with usage |

### Cost Optimization Tips

1. Use spot instances for non-critical workloads
2. Enable cluster autoscaling
3. Set appropriate resource requests/limits
4. Monitor unused resources regularly
5. Use single load balancer strategy

## 🏷️ Resource Tagging

All resources are tagged with:
- `environment` (production/development)
- `team` (infrastructure)
- `managed-by` (terraform)
- Component-specific labels

## 🔍 Monitoring & Observability

- Google Cloud Monitoring integration
- Resource quotas per namespace
- Billing alerts at $50 and $100
- Cluster and application health checks
- ArgoCD application sync status

## 📚 Documentation

- [`docs/gke-implementation-plan.MD`](docs/gke-implementation-plan.MD) - Detailed implementation plan
- [`terraform/modules/argocd-config/README.md`](terraform/modules/argocd-config/README.md) - ApplicationSet configuration guide
- Module-specific documentation in each module directory

## 🤝 Contributing

1. Follow Terraform best practices
2. Update documentation for any changes
3. Test changes in development environment first
4. Use conventional commit messages

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Troubleshooting

### Common Issues

1. **State Lock Conflicts**
   ```bash
   terraform force-unlock <lock-id>
   ```

2. **Pod Scheduling Issues**
   ```bash
   kubectl describe nodes
   kubectl get pods -o wide
   ```

3. **ArgoCD Access**
   ```bash
   kubectl get ingress -n argocd
   kubectl logs -n argocd deployment/argocd-server
   ```

### Support

- Check the [Issues](https://github.com/arigsela/terraform-gke-modules/issues) page
- Review module-specific README files
- Consult the implementation plan documentation
