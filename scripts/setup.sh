#!/bin/bash
set -e

# GKE Cluster Setup Script
# This script initializes Terraform and deploys the GKE infrastructure

ENVIRONMENT="${1:-prod}"
PROJECT_ID="chores-tracker-prod"

echo "🚀 Setting up GKE infrastructure for environment: $ENVIRONMENT"

# Check if required tools are installed
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is required but not installed." >&2; exit 1; }
command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI is required but not installed." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed." >&2; exit 1; }

# Set gcloud project
echo "📋 Setting gcloud project..."
gcloud config set project $PROJECT_ID

# Navigate to the environment directory
cd "$(dirname "$0")/../terraform/environments/$ENVIRONMENT"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found in $ENVIRONMENT environment"
    exit 1
fi

# Check if terraform-key.json exists
if [ ! -f "../../terraform-key.json" ]; then
    echo "❌ terraform-key.json not found. Please ensure service account key is in terraform/ directory"
    exit 1
fi

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate Terraform configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan the deployment
echo "📝 Planning Terraform deployment..."
terraform plan -out=tfplan

# Apply the deployment
read -p "🤔 Do you want to apply this plan? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Applying Terraform configuration..."
    terraform apply tfplan
    
    echo "✅ Infrastructure deployment completed!"
    
    # Get cluster credentials
    echo "🔑 Configuring kubectl..."
    if [ "$ENVIRONMENT" = "prod" ]; then
        gcloud container clusters get-credentials chores-tracker-cluster-prod --region us-central1 --project $PROJECT_ID
    else
        gcloud container clusters get-credentials chores-tracker-cluster-dev --zone us-central1-a --project $PROJECT_ID
    fi
    
    # Verify cluster access
    echo "🔍 Verifying cluster access..."
    kubectl get nodes
    
    # Output important information
    echo ""
    echo "🎉 Setup complete! Next steps:"
    echo "1. Install NGINX Ingress Controller"
    echo "2. Install Cert-Manager"
    echo "3. Configure DNS"
    echo "4. Deploy your applications"
    echo ""
    echo "💡 Use the following commands to get important outputs:"
    echo "   terraform output cluster_endpoint"
    echo "   terraform output ingress_ip"
    echo "   terraform output artifact_registry_url"
    
else
    echo "❌ Deployment cancelled"
    rm -f tfplan
    exit 1
fi