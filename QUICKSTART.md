# LinguaMatch - Quick Start Guide

## 🎯 You Are Here

✅ **Supabase Database:** Fully configured and running
✅ **Google Cloud Project:** Created (`lingua-match-gcp`)
🔧 **Next Step:** Complete GCP setup and deploy

---

## 🚀 Complete Setup in 3 Steps

### Step 1: Run GCP Setup Script

This will enable all required Google Cloud services and create the deployment service account:

```bash
./gcp/setup_complete.sh
```

**What it does:**
- Enables Cloud Run, Cloud Build, Artifact Registry, etc.
- Creates service account: `linguamatch-deploy@lingua-match-gcp.iam.gserviceaccount.com`
- Grants necessary IAM roles
- Generates service account key (`linguamatch-sa-key.json`)

**Time:** ~2-3 minutes

---

### Step 2: Configure GitHub Secrets

Go to your repository on GitHub:
**Settings > Secrets and Variables > Actions > New repository secret**

Add these 4 secrets:

| Secret Name | Value | Where to Find |
|------------|-------|---------------|
| `GCP_PROJECT_ID` | `lingua-match-gcp` | Project ID from GCP Console |
| `GCP_SA_KEY` | `{...entire JSON...}` | Copy full contents of `linguamatch-sa-key.json` |
| `VITE_SUPABASE_URL` | `https://cdnalhpkmzbuneywdsth.supabase.co` | From `.env.local` |
| `VITE_SUPABASE_ANON_KEY` | `eyJhbGc...` | From `.env.local` |

**⚠️ Important:**
- For `GCP_SA_KEY`, copy the **entire JSON file content** (including `{` and `}`)
- Keep `linguamatch-sa-key.json` secure and **never commit it to git**

---

### Step 3: Initialize React Application

```bash
# Create Vite React app with TypeScript
npm create vite@latest . -- --template react-ts

# Install dependencies
npm install

# Install Supabase client
npm install @supabase/supabase-js

# Install additional dependencies
npm install @tanstack/react-query zustand react-router-dom
npm install tailwindcss postcss autoprefixer
npm install react-hook-form zod @hookform/resolvers
npm install papaparse react-dropzone date-fns

# Initialize Tailwind CSS
npx tailwindcss init -p

# Install shadcn/ui
npx shadcn-ui@latest init

# Start development server
npm run dev
```

---

## 🎉 You're Ready!

### What's Working

✅ **Database:** 12 tables with Row-Level Security
✅ **Authentication:** Supabase Auth ready
✅ **Cloud Infrastructure:** GCP configured
✅ **CI/CD:** GitHub Actions ready to deploy

### Development Workflow

```bash
# Local development
npm run dev           # Start dev server at http://localhost:5173

# Build for production
npm run build         # Creates optimized production build

# Deploy manually
./gcp/deploy.sh       # Deploys to Cloud Run

# Deploy via GitHub (automatic)
git push origin main  # Triggers production deployment
```

### Access Your Services

| Service | URL |
|---------|-----|
| **Supabase Dashboard** | https://supabase.com/dashboard/project/cdnalhpkmzbuneywdsth |
| **GCP Console** | https://console.cloud.google.com/home/dashboard?project=lingua-match-gcp |
| **Local Dev** | http://localhost:5173 |
| **Production (after deploy)** | https://linguamatch-app-[hash].run.app |

---

## 📚 Next: Build Features

Follow the development phases in `README.md`:

1. **Phase 1 (Weeks 1-4):** Authentication & Basic Profiles
2. **Phase 2 (Weeks 5-8):** Connection System & Messaging
3. **Phase 3 (Weeks 9-10):** Search & Discovery
4. **Phase 4 (Weeks 11-12):** Bulk Operations & Admin
5. **Phase 5 (Weeks 13-14):** Polish & Launch

Start with creating the Supabase client in `src/lib/supabase.ts`:

```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

---

## 🆘 Troubleshooting

**Issue:** `gcloud: command not found`
**Fix:** Make sure you're authenticated: `gcloud auth login`

**Issue:** Service account key not working
**Fix:** Ensure you copied the **entire JSON** including braces `{ }`

**Issue:** GitHub Actions failing
**Fix:** Verify all 4 secrets are added correctly in GitHub repo settings

**Issue:** Supabase connection error
**Fix:** Check `.env.local` has correct URL and keys

---

## 📞 Support

- Review `SETUP_INSTRUCTIONS.md` for detailed setup
- Check `GCP_SETUP.md` for Google Cloud specifics
- See `PROJECT_STATUS.md` for current project state
- View `README.md` for complete architecture blueprint

---

**Ready to build? Run:** `./gcp/setup_complete.sh` 🚀
