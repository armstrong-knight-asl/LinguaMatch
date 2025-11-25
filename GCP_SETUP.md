# Google Cloud Platform Setup Instructions

## Project Information
- **Project Name:** googlecloud-lingua-match
- **Recommended Project ID:** googlecloud-lingua-match or lingua-match-[random]
- **Region:** us-east1 (or your preferred region)
- **Services Needed:**
  - Cloud Run (for deployment)
  - Container Registry or Artifact Registry
  - Cloud Build
  - Cloud Storage (optional, for assets)
  - Cloud SQL (optional, if needed beyond Supabase)

## Manual Project Creation

### Step 1: Create the Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click on the project dropdown at the top
3. Click "New Project"
4. Enter project details:
   - **Project Name:** `googlecloud-lingua-match`
   - **Project ID:** (will be auto-generated, note it down)
   - **Organization:** (select if applicable)
5. Click "Create"

### Step 2: Enable Required APIs
Once the project is created, enable these APIs:

```bash
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable storage.googleapis.com
```

Or enable manually in Console:
1. Go to APIs & Services > Library
2. Search and enable each:
   - Cloud Run API
   - Container Registry API
   - Cloud Build API
   - Artifact Registry API
   - Cloud Storage API

### Step 3: Set up Service Account (for CI/CD)
1. Go to IAM & Admin > Service Accounts
2. Click "Create Service Account"
3. Enter details:
   - **Name:** `linguamatch-deploy`
   - **Description:** Service account for LinguaMatch deployments
4. Grant roles:
   - Cloud Run Admin
   - Cloud Build Editor
   - Artifact Registry Writer
   - Storage Admin
5. Click "Create Key" > JSON
6. Download the key file
7. Save it securely (DO NOT commit to git)

### Step 4: Configure GitHub Actions Secret
1. Go to your GitHub repository settings
2. Navigate to Secrets and Variables > Actions
3. Add new repository secret:
   - **Name:** `GCP_SA_KEY`
   - **Value:** [paste the entire JSON content from the service account key]

### Step 5: Update Environment Variables
After creating the project, update `.env.local` with:
```bash
# Add to .env.local
VITE_GOOGLE_CLOUD_PROJECT=your-project-id
GCP_REGION=us-east1
GCP_SERVICE=linguamatch-app
```

## Automated Setup (After Project Creation)

Once you have the project ID, run:

```bash
# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
chmod +x ./gcp/enable_services.sh
./gcp/enable_services.sh

# Deploy to Cloud Run (when ready)
chmod +x ./gcp/deploy.sh
./gcp/deploy.sh
```

## Cloud Run Configuration

The application will be deployed to Cloud Run with:
- **Service Name:** linguamatch-app
- **Region:** us-east1
- **CPU:** 1
- **Memory:** 512Mi
- **Min Instances:** 0 (scales to zero when not in use)
- **Max Instances:** 10
- **Port:** 8080
- **Authentication:** Allow unauthenticated (public web app)

## Estimated Costs

**Free Tier Includes:**
- Cloud Run: 2 million requests/month
- Cloud Build: 120 build-minutes/day
- Artifact Registry: 0.5 GB storage
- Outbound data: 1 GB/month

**Expected Monthly Costs (after free tier):**
- Low traffic: $5-15/month
- Medium traffic: $30-60/month
- High traffic: $100-200/month

## Next Steps After Project Creation

1. Note your Project ID
2. Update this repository's configuration
3. Set up GitHub Actions for CI/CD
4. Deploy initial version to Cloud Run
5. Configure custom domain (optional)
6. Set up Cloud CDN (optional, for performance)

## Verification Checklist

- [ ] Project created in Google Cloud Console
- [ ] Project ID noted and saved
- [ ] Required APIs enabled
- [ ] Service account created with proper roles
- [ ] Service account key downloaded securely
- [ ] GitHub Actions secret configured
- [ ] Environment variables updated in `.env.local`
- [ ] First deployment successful
- [ ] Custom domain configured (if applicable)
