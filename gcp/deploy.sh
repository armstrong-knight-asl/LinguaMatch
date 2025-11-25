#!/bin/bash

# Deploy LinguaMatch to Google Cloud Run

set -e

echo "🚀 Deploying LinguaMatch to Cloud Run..."

# Configuration
SERVICE_NAME="linguamatch-app"
REGION="us-east1"
PLATFORM="managed"
MEMORY="512Mi"
CPU="1"
MIN_INSTANCES="0"
MAX_INSTANCES="10"
PORT="8080"

# Load environment variables if .env.local exists
if [ -f ".env.local" ]; then
    echo "📋 Loading environment variables from .env.local..."
    export $(grep -v '^#' .env.local | xargs)
fi

# Check if project is set
PROJECT_ID=${VITE_GOOGLE_CLOUD_PROJECT:-$(gcloud config get-value project 2>/dev/null)}
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No project set. Please run: gcloud config set project YOUR_PROJECT_ID"
    echo "   Or add VITE_GOOGLE_CLOUD_PROJECT to .env.local"
    exit 1
fi

echo "📋 Project: $PROJECT_ID"
echo "📍 Region: $REGION"
echo "🎯 Service: $SERVICE_NAME"

# Build and deploy
echo "🔨 Building and deploying to Cloud Run..."

gcloud run deploy "$SERVICE_NAME" \
    --source=. \
    --platform="$PLATFORM" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --memory="$MEMORY" \
    --cpu="$CPU" \
    --port="$PORT" \
    --min-instances="$MIN_INSTANCES" \
    --max-instances="$MAX_INSTANCES" \
    --allow-unauthenticated \
    --set-env-vars="VITE_SUPABASE_URL=$VITE_SUPABASE_URL,VITE_SUPABASE_ANON_KEY=$VITE_SUPABASE_ANON_KEY"

echo "✅ Deployment complete!"
echo ""
echo "🌐 Your application is now live!"
echo ""

# Get the service URL
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
    --platform="$PLATFORM" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(status.url)")

echo "🔗 URL: $SERVICE_URL"
echo ""
echo "To view logs:"
echo "  gcloud run logs read --service=$SERVICE_NAME --region=$REGION"
