#!/bin/bash
set -e

# Application Deployment Script
# This script deploys applications to the GKE cluster using kubectl/helm

ENVIRONMENT="${1:-prod}"
NAMESPACE="${2:-chores-tracker}"

echo "🚀 Deploying applications to $ENVIRONMENT environment"

# Check if kubectl is configured for the right cluster
CLUSTER_NAME="chores-tracker-cluster-$ENVIRONMENT"
CURRENT_CLUSTER=$(kubectl config current-context 2>/dev/null || echo "none")

if [[ ! "$CURRENT_CLUSTER" =~ "$CLUSTER_NAME" ]]; then
    echo "⚠️  Current kubectl context doesn't match expected cluster"
    echo "Current: $CURRENT_CLUSTER"
    echo "Expected: containing '$CLUSTER_NAME'"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Deployment cancelled"
        exit 1
    fi
fi

# Create namespace if it doesn't exist
echo "📋 Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy NGINX Ingress Controller (if not already deployed)
echo "🌐 Checking NGINX Ingress Controller..."
if ! kubectl get namespace ingress-nginx >/dev/null 2>&1; then
    echo "📦 Installing NGINX Ingress Controller..."
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    
    helm install nginx-ingress ingress-nginx/ingress-nginx \
        --namespace ingress-nginx \
        --create-namespace \
        --set controller.service.type=LoadBalancer \
        --set controller.service.annotations."cloud\.google\.com/load-balancer-type"="External" \
        --wait
else
    echo "✅ NGINX Ingress Controller already installed"
fi

# Deploy Cert-Manager (if not already deployed)
echo "🔐 Checking Cert-Manager..."
if ! kubectl get namespace cert-manager >/dev/null 2>&1; then
    echo "📦 Installing Cert-Manager..."
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    
    helm install cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --set installCRDs=true \
        --wait
else
    echo "✅ Cert-Manager already installed"
fi

# Deploy applications from kubernetes manifests (if they exist)
MANIFESTS_DIR="$(dirname "$0")/../kubernetes/apps/chores-tracker"
if [ -d "$MANIFESTS_DIR" ]; then
    echo "📋 Applying Kubernetes manifests..."
    kubectl apply -f "$MANIFESTS_DIR" -n $NAMESPACE
else
    echo "⚠️  No Kubernetes manifests found at $MANIFESTS_DIR"
fi

# Show deployment status
echo ""
echo "📊 Deployment Status:"
echo "===================="
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE
kubectl get ingress -n $NAMESPACE

echo ""
echo "✅ Deployment completed!"
echo ""
echo "🔍 Useful commands:"
echo "   kubectl get pods -n $NAMESPACE -w"
echo "   kubectl logs -f deployment/chores-tracker -n $NAMESPACE"
echo "   kubectl get ingress -n $NAMESPACE"