#!/bin/bash

# Enable required Google Cloud services for LinguaMatch

set -e

echo "🔧 Enabling Google Cloud services..."

# Check if project is set
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No project set. Please run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo "📋 Project: $PROJECT_ID"

# Array of services to enable
services=(
    "run.googleapis.com"                    # Cloud Run
    "cloudbuild.googleapis.com"             # Cloud Build
    "artifactregistry.googleapis.com"       # Artifact Registry
    "containerregistry.googleapis.com"      # Container Registry (legacy)
    "storage.googleapis.com"                # Cloud Storage
    "compute.googleapis.com"                # Compute Engine (required by Cloud Run)
    "cloudresourcemanager.googleapis.com"   # Resource Manager
)

# Enable each service
for service in "${services[@]}"; do
    echo "🔄 Enabling $service..."
    gcloud services enable "$service" --project="$PROJECT_ID"
done

echo "✅ All services enabled successfully!"
echo ""
echo "Next steps:"
echo "1. Create a service account: ./gcp/create_service_account.sh"
echo "2. Deploy the application: ./gcp/deploy.sh"
