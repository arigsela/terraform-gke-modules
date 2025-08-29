#!/bin/bash
set -e

# Container Image Migration Script
# Migrates images from ECR to Google Artifact Registry

PROJECT_ID="chores-tracker-prod"
REGION="us-central1"
REPOSITORY="chores-tracker-prod"
ECR_REGISTRY="852893458518.dkr.ecr.us-east-2.amazonaws.com"
AR_REGISTRY="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY"

echo "🐳 Migrating container images from ECR to Artifact Registry"

# Authenticate to Google Artifact Registry
echo "🔑 Authenticating to Artifact Registry..."
gcloud auth configure-docker $REGION-docker.pkg.dev

# Authenticate to ECR (requires AWS CLI configured)
echo "🔑 Authenticating to ECR..."
if command -v aws >/dev/null 2>&1; then
    aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin $ECR_REGISTRY
else
    echo "⚠️  AWS CLI not found. Please authenticate to ECR manually:"
    echo "   aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin $ECR_REGISTRY"
    read -p "Press enter after authenticating to ECR..."
fi

# Define images to migrate
IMAGES=(
    "chores-tracker:5.2.0"
    "chores-tracker:latest"
    # Add more images as needed
)

# Migrate each image
for IMAGE in "${IMAGES[@]}"; do
    echo "🔄 Migrating $IMAGE..."
    
    # Pull from ECR
    echo "⬇️  Pulling from ECR: $ECR_REGISTRY/$IMAGE"
    docker pull $ECR_REGISTRY/$IMAGE
    
    # Tag for Artifact Registry
    echo "🏷️  Tagging for Artifact Registry: $AR_REGISTRY/$IMAGE"
    docker tag $ECR_REGISTRY/$IMAGE $AR_REGISTRY/$IMAGE
    
    # Push to Artifact Registry
    echo "⬆️  Pushing to Artifact Registry: $AR_REGISTRY/$IMAGE"
    docker push $AR_REGISTRY/$IMAGE
    
    # Clean up local images
    echo "🧹 Cleaning up local images..."
    docker rmi $ECR_REGISTRY/$IMAGE $AR_REGISTRY/$IMAGE || true
    
    echo "✅ Migration completed for $IMAGE"
    echo ""
done

echo "🎉 All images migrated successfully!"
echo ""
echo "📋 Migrated images are now available at:"
for IMAGE in "${IMAGES[@]}"; do
    echo "   $AR_REGISTRY/$IMAGE"
done

echo ""
echo "💡 To use these images in Kubernetes:"
echo "   Update your deployment manifests to use the new image URLs"
echo "   Example: image: $AR_REGISTRY/chores-tracker:5.2.0"