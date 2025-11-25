#!/bin/bash

# Complete GCP Setup for LinguaMatch
# This script will set up all required GCP services and service account

set -e

echo "🚀 LinguaMatch - Complete GCP Setup"
echo "===================================="
echo ""

# Project configuration
PROJECT_ID="lingua-match-gcp"
PROJECT_NUMBER="743309039288"
REGION="us-east1"
SA_NAME="linguamatch-deploy"
SA_DISPLAY_NAME="LinguaMatch Deployment Service Account"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Project Configuration:${NC}"
echo "  Project ID: $PROJECT_ID"
echo "  Project Number: $PROJECT_NUMBER"
echo "  Region: $REGION"
echo ""

# Step 1: Set the project
echo -e "${YELLOW}Step 1: Setting GCP project...${NC}"
gcloud config set project "$PROJECT_ID"
echo -e "${GREEN}✓ Project set to $PROJECT_ID${NC}"
echo ""

# Step 2: Enable required APIs
echo -e "${YELLOW}Step 2: Enabling required Google Cloud APIs...${NC}"
echo "This may take a few minutes..."

services=(
    "run.googleapis.com"
    "cloudbuild.googleapis.com"
    "artifactregistry.googleapis.com"
    "containerregistry.googleapis.com"
    "storage.googleapis.com"
    "compute.googleapis.com"
    "cloudresourcemanager.googleapis.com"
)

for service in "${services[@]}"; do
    echo -n "  Enabling $service... "
    gcloud services enable "$service" --project="$PROJECT_ID" --quiet
    echo -e "${GREEN}✓${NC}"
done

echo -e "${GREEN}✓ All services enabled${NC}"
echo ""

# Step 3: Create service account
echo -e "${YELLOW}Step 3: Creating service account...${NC}"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Check if service account already exists
if gcloud iam service-accounts describe "$SA_EMAIL" --project="$PROJECT_ID" &>/dev/null; then
    echo -e "${YELLOW}Service account already exists: $SA_EMAIL${NC}"
else
    gcloud iam service-accounts create "$SA_NAME" \
        --display-name="$SA_DISPLAY_NAME" \
        --project="$PROJECT_ID"
    echo -e "${GREEN}✓ Service account created: $SA_EMAIL${NC}"
fi
echo ""

# Step 4: Grant IAM roles
echo -e "${YELLOW}Step 4: Granting IAM roles...${NC}"

roles=(
    "roles/run.admin"
    "roles/cloudbuild.builds.editor"
    "roles/artifactregistry.writer"
    "roles/storage.admin"
    "roles/iam.serviceAccountUser"
)

for role in "${roles[@]}"; do
    echo -n "  Granting $role... "
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SA_EMAIL" \
        --role="$role" \
        --condition=None \
        --quiet &>/dev/null
    echo -e "${GREEN}✓${NC}"
done

echo -e "${GREEN}✓ All roles granted${NC}"
echo ""

# Step 5: Create service account key
echo -e "${YELLOW}Step 5: Creating service account key...${NC}"
KEY_FILE="linguamatch-sa-key.json"

if [ -f "$KEY_FILE" ]; then
    echo -e "${YELLOW}Key file already exists: $KEY_FILE${NC}"
    read -p "Do you want to create a new key? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping key creation"
    else
        rm "$KEY_FILE"
        gcloud iam service-accounts keys create "$KEY_FILE" \
            --iam-account="$SA_EMAIL" \
            --project="$PROJECT_ID"
        echo -e "${GREEN}✓ New key file created: $KEY_FILE${NC}"
    fi
else
    gcloud iam service-accounts keys create "$KEY_FILE" \
        --iam-account="$SA_EMAIL" \
        --project="$PROJECT_ID"
    echo -e "${GREEN}✓ Key file created: $KEY_FILE${NC}"
fi
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ GCP Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Add GitHub Secrets (go to your repo Settings > Secrets and Variables > Actions):"
echo ""
echo "   Secret Name: GCP_PROJECT_ID"
echo "   Value: $PROJECT_ID"
echo ""
echo "   Secret Name: GCP_SA_KEY"
echo "   Value: [paste entire contents of $KEY_FILE]"
echo ""
echo "   Secret Name: VITE_SUPABASE_URL"
echo "   Value: https://cdnalhpkmzbuneywdsth.supabase.co"
echo ""
echo "   Secret Name: VITE_SUPABASE_ANON_KEY"
echo "   Value: [from .env.local file]"
echo ""
echo "2. Service account details:"
echo "   Email: $SA_EMAIL"
echo "   Key file: $KEY_FILE"
echo ""
echo -e "${RED}⚠️  IMPORTANT: Keep $KEY_FILE secure and DO NOT commit to git!${NC}"
echo ""
echo "3. To deploy manually:"
echo "   ./gcp/deploy.sh"
echo ""
echo "4. To deploy via GitHub Actions:"
echo "   git push origin main"
echo ""
