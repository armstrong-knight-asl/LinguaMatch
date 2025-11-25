# LinguaMatch Setup Instructions

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

3. **Database Migrations Created**
   - `supabase/migrations/001_initial_schema.sql` - Core database schema
   - `supabase/migrations/002_row_level_security.sql` - RLS policies

## 🔧 Next Steps: Run Database Migrations

### Option 1: Supabase Dashboard (Recommended)

1. Go to your Supabase project: https://supabase.com/dashboard/project/cdnalhpkmzbuneywdsth
2. Click on **SQL Editor** in the left sidebar
3. Create a new query
4. Copy the contents of `supabase/migrations/001_initial_schema.sql`
5. Paste and click **Run**
6. Create another new query
7. Copy the contents of `supabase/migrations/002_row_level_security.sql`
8. Paste and click **Run**

### Option 2: Using Supabase CLI (When Available)

```bash
# Login to Supabase
supabase login

# Link to existing project
supabase link --project-ref cdnalhpkmzbuneywdsth

# Run migrations
supabase db push
```

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
