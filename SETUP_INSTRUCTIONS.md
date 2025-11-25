# LinguaMatch Setup Instructions

## 📋 Project Overview

LinguaMatch is a two-sided marketplace connecting professional linguists with agencies. The stack includes:
- **Frontend:** React + TypeScript + Vite + Tailwind CSS
- **Backend:** Supabase (PostgreSQL + Auth + Storage + Realtime)
- **Deployment:** Google Cloud Run
- **CI/CD:** GitHub Actions

## ✅ Completed Setup

1. **Supabase Project Created**
   - Project Name: Supabase Lingua match
   - Project ID: `cdnalhpkmzbuneywdsth`
   - Region: us-east-1
   - Status: ACTIVE_HEALTHY
   - Database: PostgreSQL 17.6

2. **Environment Configuration**
   - `.env.local` created with Supabase credentials
   - `.env.example` created for team reference
   - `.gitignore` updated to protect sensitive files

3. **Database Migrations Created & Executed ✅**
   - `supabase/migrations/001_initial_schema.sql` - Core database schema
   - `supabase/migrations/002_row_level_security.sql` - RLS policies
   - All 12 tables created successfully
   - Row-Level Security enabled with 41 policies

4. **Google Cloud Platform Configuration**
   - Deployment scripts created in `gcp/` directory
   - GitHub Actions workflows for CI/CD
   - Dockerfile and nginx configuration ready
   - See `GCP_SETUP.md` for detailed instructions

## 🔧 Next Steps

### Step 1: Create Google Cloud Project

See `GCP_SETUP.md` for detailed instructions. Quick steps:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project: `googlecloud-lingua-match`
3. Note the Project ID
4. Run setup scripts:
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ./gcp/enable_services.sh
   ./gcp/create_service_account.sh
   ```
5. Add the service account key to GitHub Secrets as `GCP_SA_KEY`
6. Update `.env.local` with:
   ```bash
   VITE_GOOGLE_CLOUD_PROJECT=your-project-id
   ```

### Step 2: Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings > Secrets and Variables > Actions):

- `GCP_PROJECT_ID` - Your Google Cloud project ID
- `GCP_SA_KEY` - Service account JSON key (entire file content)
- `VITE_SUPABASE_URL` - https://cdnalhpkmzbuneywdsth.supabase.co
- `VITE_SUPABASE_ANON_KEY` - (from `.env.local`)

## 📊 Database Schema Overview

The database includes the following tables:

### Core Tables
- **users** - Extends Supabase auth.users
- **linguist_profiles** - Professional linguist profiles with CIO/CEO/CHRO/COO/CFO data
- **agency_profiles** - Agency/company profiles
- **connections** - Matching/connection requests between linguists and agencies
- **documents** - File storage for certificates, resumes, licenses, etc.
- **conversations** - Chat conversations between connected parties
- **messages** - Individual messages within conversations

### Feature Tables
- **job_postings** - Job opportunities posted by agencies
- **job_applications** - Applications from linguists to jobs
- **reviews** - Ratings and reviews
- **bulk_uploads** - Track CSV/spreadsheet imports
- **notifications** - In-app notifications

### Security
- All tables have Row-Level Security (RLS) enabled
- Policies ensure users can only access their own data and connected parties' data
- Verification status controls visibility of profiles

## 🔑 Environment Variables

Your `.env.local` file contains:
- `VITE_SUPABASE_URL` - Supabase project URL
- `VITE_SUPABASE_ANON_KEY` - Public anonymous key (safe for client-side)
- `SUPABASE_SERVICE_ROLE_KEY` - Service role key (keep secret, server-side only)
- `SUPABASE_PROJECT_ID` - Project identifier

## 🚀 Next Development Steps

After running migrations:

1. **Initialize React Project**
   ```bash
   npm create vite@latest . -- --template react-ts
   npm install
   ```

2. **Install Dependencies**
   ```bash
   npm install @supabase/supabase-js
   npm install @tanstack/react-query
   npm install zustand
   npm install react-router-dom
   npm install tailwindcss postcss autoprefixer
   npm install react-hook-form zod @hookform/resolvers
   npm install papaparse react-dropzone
   npm install date-fns
   ```

3. **Set up Tailwind CSS**
   ```bash
   npx tailwindcss init -p
   ```

4. **Install shadcn/ui**
   ```bash
   npx shadcn-ui@latest init
   ```

5. **Start building features** according to the project blueprint in README.md

## 📁 Project Structure

```
LinguaMatch/
├── supabase/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   └── 002_row_level_security.sql
│   ├── functions/        # Edge functions (to be created)
│   └── seed/            # Seed data (to be created)
├── .env.local           # Environment variables (git-ignored)
├── .env.example         # Template for environment variables
├── .gitignore           # Updated with Node/React patterns
└── README.md            # Complete project blueprint
```

## 🔒 Security Notes

- **Never commit `.env.local`** to version control
- The **service role key** bypasses RLS - use only on server-side
- The **anon key** is safe for client-side use
- All API requests through RLS policies will be scoped to the authenticated user

## 📞 Support

If you encounter issues:
1. Check Supabase project logs in the dashboard
2. Verify migrations ran successfully in SQL Editor
3. Test database connection using the REST API
4. Refer to the complete blueprint in README.md
