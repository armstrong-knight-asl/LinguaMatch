#!/bin/bash

# Create service account for LinguaMatch deployments

set -e

echo "🔐 Creating service account for LinguaMatch..."

# Configuration
SA_NAME="linguamatch-deploy"
SA_DISPLAY_NAME="LinguaMatch Deployment Service Account"
SA_DESCRIPTION="Service account for deploying LinguaMatch to Cloud Run"

# Check if project is set
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No project set. Please run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo "📋 Project: $PROJECT_ID"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Create service account
echo "🔄 Creating service account: $SA_NAME..."
gcloud iam service-accounts create "$SA_NAME" \
    --display-name="$SA_DISPLAY_NAME" \
    --description="$SA_DESCRIPTION" \
    --project="$PROJECT_ID" 2>/dev/null || echo "Service account already exists"

# Grant necessary roles
echo "🔄 Granting roles..."

roles=(
    "roles/run.admin"                  # Cloud Run Admin
    "roles/cloudbuild.builds.editor"   # Cloud Build Editor
    "roles/artifactregistry.writer"    # Artifact Registry Writer
    "roles/storage.admin"              # Storage Admin
    "roles/iam.serviceAccountUser"     # Service Account User
)

for role in "${roles[@]}"; do
    echo "  - Granting $role..."
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SA_EMAIL" \
        --role="$role" \
        --condition=None \
        --quiet
done

# Create and download key
KEY_FILE="linguamatch-sa-key.json"
echo "🔄 Creating service account key..."
gcloud iam service-accounts keys create "$KEY_FILE" \
    --iam-account="$SA_EMAIL" \
    --project="$PROJECT_ID"

echo "✅ Service account created successfully!"
echo ""
echo "📄 Service Account Email: $SA_EMAIL"
echo "🔑 Key file saved to: $KEY_FILE"
echo ""
echo "⚠️  IMPORTANT: Keep this key file secure and DO NOT commit to git!"
echo ""
echo "Next steps:"
echo "1. Add the key to GitHub Secrets:"
echo "   - Go to your repo Settings > Secrets and Variables > Actions"
echo "   - Create new secret: GCP_SA_KEY"
echo "   - Paste the ENTIRE content of $KEY_FILE"
echo ""
echo "2. Update .env.local with your project ID"
echo "3. Deploy: ./gcp/deploy.sh"
