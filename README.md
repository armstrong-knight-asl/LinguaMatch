# LinguaMatch
Project Architecture Plan
Tech Stack
Frontend: React 18+ with TypeScript
Styling: Tailwind CSS
Backend: Supabase (PostgreSQL database + Auth + Storage)
Deployment: GitHub Actions → Google Cloud Run
File Processing: Papa Parse for CSV/spreadsheet uploads
Project Structure

linguist-nexus/
├── src/
│   ├── components/
│   │   ├── interpreters/
│   │   │   ├── InterpreterCard.tsx
│   │   │   ├── InterpreterList.tsx
│   │   │   └── InterpreterProfile.tsx
│   │   ├── agencies/
│   │   │   ├── AgencyCard.tsx
│   │   │   ├── AgencyList.tsx
│   │   │   └── AgencyProfile.tsx
│   │   ├── shared/
│   │   │   ├── AccordionItem.tsx
│   │   │   ├── Field.tsx
│   │   │   ├── Badge.tsx
│   │   │   └── UploadSpreadsheet.tsx
│   │   └── layout/
│   │       ├── Header.tsx
│   │       ├── Navigation.tsx
│   │       └── Footer.tsx
│   ├── pages/
│   │   ├── InterpretersPage.tsx
│   │   ├── AgenciesPage.tsx
│   │   └── HomePage.tsx
│   ├── services/
│   │   ├── supabase.ts
│   │   └── csvParser.ts
│   ├── types/
│   │   ├── interpreter.ts
│   │   └── agency.ts
│   ├── hooks/
│   │   ├── useInterpreters.ts
│   │   └── useAgencies.ts
│   ├── App.tsx
│   └── main.tsx
├── public/
├── supabase/
│   ├── migrations/
│   └── seed.sql
└── package.json
Database Schema (Supabase)
Interpreters Table:


sql
- id (uuid, primary key)
- contracting_as (text[])
- source_lang (text)
- target_lang (text)
- cio_data (jsonb)
- ceo_data (jsonb)
- chro_data (jsonb)
- coo_data (jsonb)
- cfo_data (jsonb)
- created_at (timestamp)
- updated_at (timestamp)
Agencies Table:


sql
- id (uuid, primary key)
- name (text)
- contact_info (jsonb)
- service_areas (text[])
- interpreters (uuid[]) -- references interpreters
- created_at (timestamp)
- updated_at (timestamp)
Key Features to Implement
Two-Page Navigation
Interpreters page with filterable list
Agencies page with associated interpreters
Smooth routing between pages
Spreadsheet Upload
CSV/Excel file upload component
Data validation and parsing
Bulk import to Supabase
Error handling and preview
Profile Views
Reuse your existing accordion design
Responsive cards for list views
Search and filter functionality
Would you like me to:

Start building the React app structure with routing and main components?
Create the Supabase setup scripts (migrations, schemas)?
Build the spreadsheet upload component with CSV parsing?
Set up the deployment pipeline (GitHub Actions + Google Cloud)?
Which part would you like me to tackle first?




Retry
A





2 / 2
LINGUAMATCH - Complete Blueprint
🎯 Executive Summary
LINGUAMATCH is a two-sided marketplace platform connecting professional linguists (interpreters/translators) with agencies seeking language services. Think "LinkedIn meets Upwork" for the language services industry.

🏗️ System Architecture
High-Level Architecture

┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                             │
│  ┌──────────────────┐         ┌──────────────────┐         │
│  │  Linguist Portal │         │  Agency Portal   │         │
│  │  (React SPA)     │         │  (React SPA)     │         │
│  └──────────────────┘         └──────────────────┘         │
└─────────────────────────────────────────────────────────────┘
                            ↓ ↑
┌─────────────────────────────────────────────────────────────┐
│                    API GATEWAY LAYER                         │
│              (Supabase Edge Functions)                       │
│  Authentication • Authorization • Rate Limiting              │
└─────────────────────────────────────────────────────────────┘
                            ↓ ↑
┌─────────────────────────────────────────────────────────────┐
│                   SERVICE LAYER                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ Profile  │ │ Matching │ │ Document │ │ Messaging│      │
│  │ Service  │ │ Engine   │ │ Service  │ │ Service  │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓ ↑
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER                                │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐ │
│  │   Supabase     │  │  Supabase      │  │   Supabase   │ │
│  │   PostgreSQL   │  │  Storage       │  │   Realtime   │ │
│  │   (Database)   │  │  (Files/Docs)  │  │   (Chat)     │ │
│  └────────────────┘  └────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓ ↑
┌─────────────────────────────────────────────────────────────┐
│                 EXTERNAL SERVICES                            │
│  Google Cloud • GitHub • Email Service • Payment Gateway     │
└─────────────────────────────────────────────────────────────┘
📊 Database Schema Design
Core Tables
1. users (Supabase Auth Extended)

sql
- id (uuid, FK to auth.users)
- user_type (enum: 'linguist', 'agency')
- email (text, unique)
- created_at (timestamp)
- updated_at (timestamp)
- last_login (timestamp)
- profile_completed (boolean)
- verification_status (enum: 'pending', 'verified', 'rejected')
2. linguist_profiles

sql
- id (uuid, PK)
- user_id (uuid, FK to users.id)
- profile_visibility (enum: 'public', 'private', 'verified_only')

-- Personal Information
- display_name (text)
- professional_title (text)
- profile_photo_url (text)
- bio (text)

-- Language Pairs
- source_languages (text[])
- target_languages (text[])
- language_pairs (jsonb[]) -- [{source: 'EN', target: 'ES', proficiency: 'native'}]

-- Professional Details (Your CIO/CEO/CHRO/COO/CFO structure)
- cio_data (jsonb) -- Front desk, contact, location
- ceo_data (jsonb) -- Legal entity, business stats
- chro_data (jsonb) -- Background, education, certifications
- coo_data (jsonb) -- Operations, logistics, scheduling
- cfo_data (jsonb) -- Rates, payment terms, invoicing

-- Specializations
- service_types (text[]) -- ['medical', 'legal', 'conference', 'consecutive']
- industries (text[]) -- ['healthcare', 'legal', 'education']
- certifications (jsonb[])
- education (jsonb[])

-- Availability
- available_for_hire (boolean)
- work_modes (text[]) -- ['remote', 'on-site', 'hybrid']
- timezone (text)
- standard_hours (jsonb)

-- Metrics
- jobs_completed (integer)
- average_rating (decimal)
- response_time_hours (decimal)
- profile_views (integer)

-- Timestamps
- created_at (timestamp)
- updated_at (timestamp)
- last_active (timestamp)
3. agency_profiles

sql
- id (uuid, PK)
- user_id (uuid, FK to users.id)
- profile_visibility (enum: 'public', 'private')

-- Company Information
- company_name (text)
- company_logo_url (text)
- company_type (enum: 'agency', 'enterprise', 'government', 'nonprofit')
- description (text)
- founded_year (integer)
- company_size (text) -- '1-10', '11-50', '51-200', etc.

-- Contact & Location
- primary_contact (jsonb)
- headquarters_address (jsonb)
- service_regions (text[])
- website (text)
- social_links (jsonb)

-- Business Details
- business_license_number (text)
- tax_id_available (boolean)
- incorporation_state (text)
- insurance_coverage (jsonb)

-- Service Requirements
- languages_needed (text[])
- industries_served (text[])
- typical_project_types (text[])
- volume_per_month (text) -- 'low', 'medium', 'high'

-- Payment & Terms
- payment_terms (jsonb)
- rate_ranges (jsonb)
- preferred_payment_methods (text[])

-- Metrics
- active_linguists (integer)
- projects_posted (integer)
- average_rating (decimal)
- response_time_hours (decimal)

-- Timestamps
- created_at (timestamp)
- updated_at (timestamp)
- last_active (timestamp)
4. connections (The Matching Table)

sql
- id (uuid, PK)
- linguist_id (uuid, FK to linguist_profiles.id)
- agency_id (uuid, FK to agency_profiles.id)
- status (enum: 'pending', 'accepted', 'declined', 'blocked')
- initiated_by (enum: 'linguist', 'agency')
- connection_type (enum: 'inquiry', 'invitation', 'application')
- message (text) -- Initial connection message
- metadata (jsonb) -- Additional context
- created_at (timestamp)
- updated_at (timestamp)
- responded_at (timestamp)

UNIQUE(linguist_id, agency_id)
5. documents

sql
- id (uuid, PK)
- owner_id (uuid, FK to users.id)
- owner_type (enum: 'linguist', 'agency')
- document_type (enum: 'resume', 'certificate', 'license', 'insurance', 
                       'contract', 'w9', 'business_license', 'other')
- file_name (text)
- file_url (text) -- Supabase Storage URL
- file_size (integer)
- mime_type (text)
- verification_status (enum: 'pending', 'verified', 'rejected')
- verified_by (uuid, nullable, FK to users.id)
- verified_at (timestamp, nullable)
- visibility (enum: 'private', 'connections_only', 'verified_agencies', 'public')
- expiration_date (date, nullable) -- For licenses/certifications
- metadata (jsonb)
- created_at (timestamp)
- updated_at (timestamp)
6. conversations

sql
- id (uuid, PK)
- linguist_id (uuid, FK to linguist_profiles.id)
- agency_id (uuid, FK to agency_profiles.id)
- connection_id (uuid, FK to connections.id)
- status (enum: 'active', 'archived', 'blocked')
- last_message_at (timestamp)
- unread_count_linguist (integer)
- unread_count_agency (integer)
- created_at (timestamp)
7. messages

sql
- id (uuid, PK)
- conversation_id (uuid, FK to conversations.id)
- sender_id (uuid, FK to users.id)
- sender_type (enum: 'linguist', 'agency')
- message_type (enum: 'text', 'file', 'system')
- content (text)
- attachments (jsonb[])
- read_at (timestamp, nullable)
- created_at (timestamp)
8. job_postings (Future Enhancement)

sql
- id (uuid, PK)
- agency_id (uuid, FK to agency_profiles.id)
- title (text)
- description (text)
- language_pair (jsonb)
- service_type (text)
- work_mode (enum: 'remote', 'on-site', 'hybrid')
- location (jsonb)
- start_date (date)
- duration (text)
- rate_range (jsonb)
- requirements (jsonb)
- status (enum: 'draft', 'active', 'filled', 'cancelled')
- applications_count (integer)
- created_at (timestamp)
- expires_at (timestamp)
9. job_applications (Future Enhancement)

sql
- id (uuid, PK)
- job_id (uuid, FK to job_postings.id)
- linguist_id (uuid, FK to linguist_profiles.id)
- cover_letter (text)
- proposed_rate (decimal)
- status (enum: 'pending', 'shortlisted', 'accepted', 'rejected', 'withdrawn')
- created_at (timestamp)
- updated_at (timestamp)
10. reviews

sql
- id (uuid, PK)
- reviewer_id (uuid, FK to users.id)
- reviewer_type (enum: 'linguist', 'agency')
- reviewee_id (uuid, FK to users.id)
- reviewee_type (enum: 'linguist', 'agency')
- connection_id (uuid, FK to connections.id)
- rating (integer) -- 1-5
- review_text (text)
- categories (jsonb) -- {communication: 5, professionalism: 4, etc}
- response (text, nullable) -- Reviewee can respond
- status (enum: 'published', 'flagged', 'hidden')
- created_at (timestamp)
11. bulk_uploads

sql
- id (uuid, PK)
- uploaded_by (uuid, FK to users.id)
- upload_type (enum: 'linguists', 'agencies')
- file_name (text)
- file_url (text)
- total_records (integer)
- processed_records (integer)
- successful_records (integer)
- failed_records (integer)
- error_log (jsonb)
- status (enum: 'pending', 'processing', 'completed', 'failed')
- created_at (timestamp)
- completed_at (timestamp, nullable)
12. notifications

sql
- id (uuid, PK)
- user_id (uuid, FK to users.id)
- type (enum: 'connection_request', 'message', 'document_verified', 
             'profile_view', 'review_received', 'system')
- title (text)
- content (text)
- action_url (text, nullable)
- read_at (timestamp, nullable)
- created_at (timestamp)
Indexes & Constraints

sql
-- Performance Indexes
CREATE INDEX idx_linguist_languages ON linguist_profiles USING GIN(source_languages);
CREATE INDEX idx_linguist_target_languages ON linguist_profiles USING GIN(target_languages);
CREATE INDEX idx_linguist_available ON linguist_profiles(available_for_hire) WHERE available_for_hire = true;
CREATE INDEX idx_agency_languages ON agency_profiles USING GIN(languages_needed);
CREATE INDEX idx_connections_status ON connections(status, created_at DESC);
CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);

-- Full-text Search
CREATE INDEX idx_linguist_search ON linguist_profiles USING GIN(
  to_tsvector('english', display_name || ' ' || bio)
);
CREATE INDEX idx_agency_search ON agency_profiles USING GIN(
  to_tsvector('english', company_name || ' ' || description)
);
```

---

## 🎨 Frontend Architecture

### Technology Stack
```
- React 18.3+ (with TypeScript)
- React Router v6 (routing)
- TanStack Query (data fetching & caching)
- Zustand (global state management)
- Tailwind CSS + shadcn/ui (styling)
- React Hook Form + Zod (forms & validation)
- Papa Parse (CSV parsing)
- React Dropzone (file uploads)
- date-fns (date handling)
- Recharts (data visualization)
```

### Folder Structure
```
linguamatch/
├── public/
│   ├── favicon.ico
│   ├── logo.svg
│   └── robots.txt
│
├── src/
│   ├── app/
│   │   ├── App.tsx
│   │   ├── routes.tsx
│   │   └── providers.tsx
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── components/
│   │   │   │   ├── LoginForm.tsx
│   │   │   │   ├── SignupForm.tsx
│   │   │   │   └── UserTypeSelector.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useAuth.ts
│   │   │   │   └── useSession.ts
│   │   │   ├── services/
│   │   │   │   └── authService.ts
│   │   │   └── types/
│   │   │       └── auth.types.ts
│   │   │
│   │   ├── linguist/
│   │   │   ├── components/
│   │   │   │   ├── profile/
│   │   │   │   │   ├── LinguistProfileView.tsx
│   │   │   │   │   ├── LinguistProfileEdit.tsx
│   │   │   │   │   ├── CIOSection.tsx
│   │   │   │   │   ├── CEOSection.tsx
│   │   │   │   │   ├── CHROSection.tsx
│   │   │   │   │   ├── COOSection.tsx
│   │   │   │   │   └── CFOSection.tsx
│   │   │   │   ├── search/
│   │   │   │   │   ├── LinguistCard.tsx
│   │   │   │   │   ├── LinguistList.tsx
│   │   │   │   │   └── LinguistFilters.tsx
│   │   │   │   └── dashboard/
│   │   │   │       ├── LinguistDashboard.tsx
│   │   │   │       ├── ConnectionRequests.tsx
│   │   │   │       └── ActiveConnections.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useLinguistProfile.ts
│   │   │   │   ├── useLinguistSearch.ts
│   │   │   │   └── useLinguistStats.ts
│   │   │   ├── services/
│   │   │   │   └── linguistService.ts
│   │   │   └── types/
│   │   │       └── linguist.types.ts
│   │   │
│   │   ├── agency/
│   │   │   ├── components/
│   │   │   │   ├── profile/
│   │   │   │   │   ├── AgencyProfileView.tsx
│   │   │   │   │   ├── AgencyProfileEdit.tsx
│   │   │   │   │   └── CompanyInfoForm.tsx
│   │   │   │   ├── search/
│   │   │   │   │   ├── AgencyCard.tsx
│   │   │   │   │   ├── AgencyList.tsx
│   │   │   │   │   └── AgencyFilters.tsx
│   │   │   │   └── dashboard/
│   │   │   │       ├── AgencyDashboard.tsx
│   │   │   │       ├── SavedLinguists.tsx
│   │   │   │       └── ActiveProjects.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useAgencyProfile.ts
│   │   │   │   └── useAgencySearch.ts
│   │   │   ├── services/
│   │   │   │   └── agencyService.ts
│   │   │   └── types/
│   │   │       └── agency.types.ts
│   │   │
│   │   ├── connections/
│   │   │   ├── components/
│   │   │   │   ├── ConnectionCard.tsx
│   │   │   │   ├── ConnectionModal.tsx
│   │   │   │   ├── ConnectionList.tsx
│   │   │   │   └── ConnectionActions.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useConnections.ts
│   │   │   │   └── useConnectionActions.ts
│   │   │   ├── services/
│   │   │   │   └── connectionService.ts
│   │   │   └── types/
│   │   │       └── connection.types.ts
│   │   │
│   │   ├── messaging/
│   │   │   ├── components/
│   │   │   │   ├── ConversationList.tsx
│   │   │   │   ├── ChatWindow.tsx
│   │   │   │   ├── MessageBubble.tsx
│   │   │   │   └── MessageInput.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useConversations.ts
│   │   │   │   ├── useMessages.ts
│   │   │   │   └── useRealtimeMessages.ts
│   │   │   ├── services/
│   │   │   │   └── messagingService.ts
│   │   │   └── types/
│   │   │       └── messaging.types.ts
│   │   │
│   │   ├── documents/
│   │   │   ├── components/
│   │   │   │   ├── DocumentUpload.tsx
│   │   │   │   ├── DocumentList.tsx
│   │   │   │   ├── DocumentViewer.tsx
│   │   │   │   └── VerificationBadge.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useDocuments.ts
│   │   │   │   └── useDocumentUpload.ts
│   │   │   ├── services/
│   │   │   │   └── documentService.ts
│   │   │   └── types/
│   │   │       └── document.types.ts
│   │   │
│   │   ├── bulk-upload/
│   │   │   ├── components/
│   │   │   │   ├── SpreadsheetUploader.tsx
│   │   │   │   ├── DataPreview.tsx
│   │   │   │   ├── MappingInterface.tsx
│   │   │   │   ├── ValidationResults.tsx
│   │   │   │   └── UploadHistory.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useBulkUpload.ts
│   │   │   │   └── useCSVParser.ts
│   │   │   ├── services/
│   │   │   │   └── bulkUploadService.ts
│   │   │   └── types/
│   │   │       └── bulkUpload.types.ts
│   │   │
│   │   ├── search/
│   │   │   ├── components/
│   │   │   │   ├── UnifiedSearch.tsx
│   │   │   │   ├── AdvancedFilters.tsx
│   │   │   │   ├── SearchResults.tsx
│   │   │   │   └── SavedSearches.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useSearch.ts
│   │   │   │   └── useFilters.ts
│   │   │   └── services/
│   │   │       └── searchService.ts
│   │   │
│   │   └── notifications/
│   │       ├── components/
│   │       │   ├── NotificationBell.tsx
│   │       │   ├── NotificationList.tsx
│   │       │   └── NotificationItem.tsx
│   │       ├── hooks/
│   │       │   ├── useNotifications.ts
│   │       │   └── useRealtimeNotifications.ts
│   │       └── services/
│   │           └── notificationService.ts
│   │
│   ├── components/
│   │   ├── ui/ (shadcn components)
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── dropdown-menu.tsx
│   │   │   ├── form.tsx
│   │   │   ├── input.tsx
│   │   │   ├── select.tsx
│   │   │   ├── tabs.tsx
│   │   │   ├── accordion.tsx
│   │   │   └── ...
│   │   ├── layout/
│   │   │   ├── AppLayout.tsx
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── MobileNav.tsx
│   │   ├── shared/
│   │   │   ├── AccordionItem.tsx (Your existing component)
│   │   │   ├── Field.tsx (Your existing component)
│   │   │   ├── Badge.tsx (Your existing component)
│   │   │   ├── LoadingSpinner.tsx
│   │   │   ├── ErrorBoundary.tsx
│   │   │   ├── EmptyState.tsx
│   │   │   └── ConfirmDialog.tsx
│   │   └── forms/
│   │       ├── FormField.tsx
│   │       ├── FormSection.tsx
│   │       └── FormActions.tsx
│   │
│   ├── lib/
│   │   ├── supabase.ts (Supabase client)
│   │   ├── queryClient.ts (TanStack Query config)
│   │   ├── utils.ts (Helper functions)
│   │   ├── constants.ts
│   │   └── validation.ts (Zod schemas)
│   │
│   ├── hooks/
│   │   ├── useMediaQuery.ts
│   │   ├── useDebounce.ts
│   │   ├── useLocalStorage.ts
│   │   └── useToast.ts
│   │
│   ├── stores/
│   │   ├── authStore.ts (Zustand)
│   │   ├── uiStore.ts
│   │   └── searchStore.ts
│   │
│   ├── types/
│   │   ├── index.ts
│   │   ├── database.types.ts (Generated from Supabase)
│   │   └── common.types.ts
│   │
│   ├── pages/
│   │   ├── HomePage.tsx
│   │   ├── LoginPage.tsx
│   │   ├── SignupPage.tsx
│   │   ├── LinguistDashboardPage.tsx
│   │   ├── AgencyDashboardPage.tsx
│   │   ├── SearchPage.tsx
│   │   ├── ProfilePage.tsx
│   │   ├── ConnectionsPage.tsx
│   │   ├── MessagesPage.tsx
│   │   ├── DocumentsPage.tsx
│   │   ├── SettingsPage.tsx
│   │   └── NotFoundPage.tsx
│   │
│   ├── styles/
│   │   ├── globals.css
│   │   └── tailwind.css
│   │
│   ├── main.tsx
│   └── vite-env.d.ts
│
├── supabase/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_add_connections.sql
│   │   └── ...
│   ├── functions/
│   │   ├── matching-engine/
│   │   ├── email-notifications/
│   │   └── ...
│   └── seed.sql
│
├── .github/
│   └── workflows/
│       ├── deploy-staging.yml
│       └── deploy-production.yml
│
├── package.json
├── tsconfig.json
├── vite.config.ts
├── tailwind.config.js
├── .env.example
└── README.md
Page Routes

typescript
const routes = {
  // Public
  home: '/',
  login: '/login',
  signup: '/signup',
  aboutus: '/about',
  
  // Linguist Portal
  linguistDashboard: '/linguist/dashboard',
  linguistProfile: '/linguist/profile',
  linguistProfileEdit: '/linguist/profile/edit',
  linguistConnections: '/linguist/connections',
  linguistMessages: '/linguist/messages',
  linguistDocuments: '/linguist/documents',
  linguistSettings: '/linguist/settings',
  
  // Agency Portal
  agencyDashboard: '/agency/dashboard',
  agencyProfile: '/agency/profile',
  agencyProfileEdit: '/agency/profile/edit',
  agencyConnections: '/agency/connections',
  agencyMessages: '/agency/messages',
  agencyDocuments: '/agency/documents',
  agencyBulkUpload: '/agency/bulk-upload',
  agencySettings: '/agency/settings',
  
  // Shared/Search
  searchLinguists: '/search/linguists',
  searchAgencies: '/search/agencies',
  viewProfile: '/profile/:userId',
  
  // Admin (future)
  admin: '/admin',
};
```

---

## 🔐 Authentication & Authorization

### Auth Flow
```
1. User Registration
   ├─> Select user type (Linguist/Agency)
   ├─> Email/Password signup via Supabase Auth
   ├─> Email verification required
   ├─> Create user record in users table
   └─> Redirect to profile setup

2. Profile Setup (Multi-step wizard)
   Linguist:
   ├─> Step 1: Basic Info (name, languages)
   ├─> Step 2: Professional Details (CIO/CEO/CHRO)
   ├─> Step 3: Rates & Availability (COO/CFO)
   ├─> Step 4: Documents Upload
   └─> Step 5: Review & Publish
   
   Agency:
   ├─> Step 1: Company Info
   ├─> Step 2: Service Requirements
   ├─> Step 3: Documents Upload
   └─> Step 4: Review & Publish

3. Login
   ├─> Email/Password via Supabase Auth
   ├─> Fetch user type from users table
   └─> Redirect to appropriate dashboard

4. Password Reset
   └─> Supabase magic link flow
Row-Level Security (RLS) Policies

sql
-- Linguist Profiles
-- Public profiles visible to all verified agencies
CREATE POLICY "Public linguist profiles visible to verified agencies"
  ON linguist_profiles FOR SELECT
  USING (
    profile_visibility = 'public'
    OR (profile_visibility = 'verified_only' 
        AND auth.uid() IN (
          SELECT user_id FROM agency_profiles 
          WHERE verification_status = 'verified'
        ))
  );

-- Linguists can update their own profile
CREATE POLICY "Linguists can update own profile"
  ON linguist_profiles FOR UPDATE
  USING (user_id = auth.uid());

-- Agency Profiles
CREATE POLICY "Verified agencies visible to linguists"
  ON agency_profiles FOR SELECT
  USING (verification_status = 'verified');

-- Agencies can update their own profile
CREATE POLICY "Agencies can update own profile"
  ON agency_profiles FOR UPDATE
  USING (user_id = auth.uid());

-- Connections
-- Users can see connections they're part of
CREATE POLICY "Users can view their connections"
  ON connections FOR SELECT
  USING (
    linguist_id IN (SELECT id FROM linguist_profiles WHERE user_id = auth.uid())
    OR agency_id IN (SELECT id FROM agency_profiles WHERE user_id = auth.uid())
  );

-- Documents
-- Users can only see their own private documents
CREATE POLICY "Users view own documents"
  ON documents FOR SELECT
  USING (owner_id = auth.uid());

-- Connected parties can see shared documents
CREATE POLICY "Connected parties view shared documents"
  ON documents FOR SELECT
  USING (
    visibility = 'public'
    OR (visibility = 'connections_only' AND owner_id IN (
      SELECT linguist_id FROM connections 
      WHERE agency_id IN (SELECT id FROM agency_profiles WHERE user_id = auth.uid())
        AND status = 'accepted'
      UNION
      SELECT agency_id FROM connections 
      WHERE linguist_id IN (SELECT id FROM linguist_profiles WHERE user_id = auth.uid())
        AND status = 'accepted'
    ))
  );
```

---

## 🔄 Core User Flows

### Flow 1: Agency Searches for Linguist
```
1. Agency logs in → Agency Dashboard
2. Clicks "Find Linguists" → Search Page
3. Sets filters:
   - Language pair (Spanish → English)
   - Service type (Medical interpretation)
   - Location (Remote)
   - Rate range ($50-$100/hr)
   - Availability (Next 7 days)
4. Views search results (cards with key info)
5. Clicks linguist card → Full Profile View
   - See all CIO/CEO/CHRO/COO/CFO sections
   - View certifications, documents
   - See reviews/ratings
6. Clicks "Connect" button
7. Modal appears: "Send Connection Request"
   - Pre-filled message template
   - Option to customize message
   - Attach project brief (optional)
8. Submits request
9. Notification sent to linguist
10. Connection appears in "Pending Connections"
```

### Flow 2: Linguist Receives & Responds to Connection
```
1. Linguist receives notification (email + in-app)
2. Logs in → sees notification badge
3. Clicks notification → Connection Request page
4. Views agency profile:
   - Company info
   - Projects they've posted
   - Reviews from other linguists
5. Reads connection message
6. Options:
   a) Accept → Opens messaging thread
   b) Decline with reason → Sends polite decline
   c) Ask for more info → Opens messaging thread
7. If accepted:
   - Connection moves to "Active Connections"
   - Both parties can now message freely
   - Documents become visible (per visibility settings)
   - Can share rates, contracts, etc.
```

### Flow 3: Bulk Upload (Agency)
```
1. Agency → Bulk Upload Page
2. Downloads CSV template
3. Fills out linguist data:
   - Name, Email, Languages, Rates, etc.
4. Uploads CSV file
5. System validates:
   - Email format
   - Required fields
   - Data types
   - Duplicate checks
6. Preview page shows:
   - Total records: 50
   - Valid records: 48
   - Errors: 2 (with details)
7. Agency reviews errors:
   - Missing email on row 12
   - Invalid rate format on row 35
8. Options:
   a) Fix in spreadsheet & re-upload
   b) Proceed with valid records only
9. Clicks "Import Valid Records"
10. Background job processes:
    - Creates linguist_profiles
    - Sends invitation emails
    - Logs import in bulk_uploads table
11. Success page shows summary
12. Linguists receive invitation emails with signup link
```

### Flow 4: Document Upload & Verification
```
Linguist side:
1. Profile → Documents tab
2. Clicks "Upload Document"
3. Selects document type (Resume, Certificate, etc.)
4. Drags & drops file or browses
5. Sets visibility:
   - Private (only me)
   - Connected agencies only
   - Verified agencies
   - Public
6. Uploads to Supabase Storage
7. Document appears with "Pending Verification" badge

Agency side (viewing linguist profile):
1. Views linguist profile
2. Documents section shows:
   - Verified documents: Green checkmark
   - Pending verification: Yellow badge
   - Can request verification if needed
   
Admin verification (future):
1. Admin reviews document
2. Marks as verified or requests changes
3. Linguist receives notification
```

### Flow 5: Messaging Between Parties
```
1. From active connection, click "Message"
2. Opens chat window (Realtime via Supabase)
3. Can send:
   - Text messages
   - File attachments
   - Links
4. Features:
   - Read receipts
   - Typing indicators
   - Message search
   - Archive conversations
5. Push notifications for new messages
6. All messages stored in messages table
🧠 Smart Matching Algorithm (Future Phase)
Matching Logic

typescript
interface MatchCriteria {
  languagePairMatch: number;      // 40% weight
  rateCompatibility: number;       // 20% weight
  availabilityMatch: number;       // 15% weight
  industryExperience: number;      // 10% weight
  locationProximity: number;       // 10% weight
  reviewScore: number;             // 5% weight
}

function calculateMatchScore(
  linguist: LinguistProfile,
  agency: AgencyProfile
): number {
  // Algorithm implementation
  // Returns 0-100 match score
}
```

### Suggested Matches Feature
- Daily/weekly email with top matches
- "You might be interested in..." section on dashboard
- ML-based recommendations over time

---

## 📁 File Upload & Storage Strategy

### Supabase Storage Buckets
```
linguamatch-documents/
├── linguist-documents/
│   ├── {linguist_id}/
│   │   ├── resume/
│   │   ├── certificates/
│   │   ├── licenses/
│   │   └── contracts/
│
├── agency-documents/
│   ├── {agency_id}/
│   │   ├── business-license/
│   │   ├── insurance/
│   │   └── contracts/
│
├── message-attachments/
│   └── {conversation_id}/
│
└── bulk-uploads/
    └── {upload_id}/
File Upload Flow

typescript
1. Client validates file (size, type)
2. Generate unique filename
3. Upload to Supabase Storage
4. Get public/signed URL
5. Create document record in DB
6. Show upload progress
7. Handle errors gracefully
CSV Template Structure

csv
For Linguists:
email,first_name,last_name,source_languages,target_languages,service_types,hourly_rate,phone,city,state,certifications,years_experience

For Agencies:
company_name,contact_email,contact_name,phone,address,city,state,website,languages_needed,industries,company_size
🔔 Notification System
Notification Types & Triggers

typescript
enum NotificationType {
  // Connection Events
  CONNECTION_REQUEST = 'connection_request',
  CONNECTION_ACCEPTED = 'connection_accepted',
  CONNECTION_DECLINED = 'connection_declined',
  
  // Messaging
  NEW_MESSAGE = 'new_message',
  
  // Documents
  DOCUMENT_VERIFIED = 'document_verified',
  DOCUMENT_REJECTED = 'document_rejected',
  DOCUMENT_EXPIRING = 'document_expiring',
  
  // Profile
  PROFILE_VIEWED = 'profile_viewed',
  SAVED_BY_AGENCY = 'saved_by_agency',
  
  // Reviews
  REVIEW_RECEIVED = 'review_received',
  
  // System
  ACCOUNT_VERIFIED = 'account_verified',
  WEEKLY_DIGEST = 'weekly_digest',
}
```

### Delivery Channels
- In-app (real-time via Supabase Realtime)
- Email (via Supabase Edge Functions + SendGrid/Resend)
- Push notifications (future, via service worker)

---

## 🚀 Deployment Architecture

### Environment Strategy
```
Development:
- Local Supabase instance
- Local Vite dev server
- Test data seeding

Staging:
- Supabase staging project
- Google Cloud Run (staging)
- Staging domain: staging.linguamatch.com

Production:
- Supabase production project
- Google Cloud Run (production)
- Production domain: linguamatch.com
CI/CD Pipeline (GitHub Actions)

yaml
Workflow:
1. On push to 'develop' branch:
   - Run tests
   - Build React app
   - Deploy to staging
   - Run E2E tests
   
2. On push to 'main' branch (via PR):
   - Run tests
   - Build React app
   - Deploy to production
   - Health check
   - Rollback on failure

3. Database migrations:
   - Run via Supabase CLI
   - Separate workflow
   - Requires manual approval for production
Build Configuration

dockerfile
# Dockerfile for Cloud Run
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 8080
CMD ["npm", "run", "preview"]
```

---

## 📊 Analytics & Monitoring

### Key Metrics to Track
```
User Metrics:
- New signups (linguist vs agency)
- Profile completion rate
- Active users (DAU/MAU)
- User retention rate

Engagement Metrics:
- Connection requests sent/received
- Connection acceptance rate
- Messages sent
- Average response time
- Document uploads

Business Metrics:
- Successful matches
- Revenue per connection (future)
- Churn rate
- User satisfaction (NPS)
```

### Tools
- Supabase Dashboard (built-in analytics)
- Google Analytics 4
- Sentry (error tracking)
- LogRocket (session replay)

---

## 🔒 Security Considerations

### Frontend Security
- Implement CSP headers
- XSS protection (React handles most)
- CSRF tokens for sensitive actions
- Input validation (client & server)
- Rate limiting on API calls

### Backend Security
- Row-Level Security (RLS) on all tables
- API rate limiting (Supabase Edge Functions)
- File upload validation (size, type, malware scan)
- Encrypted sensitive data (PII)
- Audit logs for admin actions

### Compliance
- GDPR compliance (data export, deletion)
- CCPA compliance
- Data retention policies
- Privacy policy & terms of service
- Cookie consent

---

## 🧪 Testing Strategy

### Test Pyramid
```
E2E Tests (10%):
- Critical user flows
- Connection flow
- Messaging flow
- Document upload

Integration Tests (30%):
- API endpoints
- Database operations
- File uploads
- Authentication

Unit Tests (60%):
- React components
- Utility functions
- Form validation
- State management
```

### Testing Tools
- Vitest (unit tests)
- Testing Library (component tests)
- Playwright (E2E tests)
- MSW (API mocking)

---

## 📅 Development Phases & Timeline

### Phase 1: Foundation (Weeks 1-4)
```
Week 1-2: Setup & Core Infrastructure
- Initialize React + TypeScript project
- Configure Tailwind + shadcn/ui
- Set up Supabase project
- Create database schema
- Implement RLS policies
- Set up GitHub repo & CI/CD

Week 3-4: Authentication & Basic Profiles
- Build auth system (login, signup, reset)
- Create user type selection
- Build basic profile forms
- Implement profile view components
- File upload infrastructure
```

### Phase 2: Core Features (Weeks 5-8)
```
Week 5-6: Connection System
- Build connection request flow
- Implement connection management
- Create connection status tracking
- Build notification system (basic)

Week 7-8: Messaging System
- Implement real-time chat
- Build conversation UI
- Add file attachments in messages
- Create message notifications
```

### Phase 3: Search & Discovery (Weeks 9-10)
```
Week 9: Search Functionality
- Build linguist search
- Build agency search
- Implement advanced filters
- Add saved searches

Week 10: Profile Enhancement
- Complete CIO/CEO/CHRO/COO/CFO sections
- Add document management
- Implement profile visibility settings
- Add profile analytics (views, saves)
```

### Phase 4: Bulk Operations & Admin (Weeks 11-12)
```
Week 11: Bulk Upload
- CSV template creation
- File parsing & validation
- Data mapping interface
- Import processing
- Error handling & reporting

Week 12: Admin Panel (basic)
- User verification system
- Document verification
- Basic moderation tools
- Analytics dashboard
```

### Phase 5: Polish & Launch Prep (Weeks 13-14)
```
Week 13: UX/UI Polish
- Responsive design refinement
- Loading states
- Error handling UI
- Accessibility improvements
- Performance optimization

Week 14: Testing & Deployment
- E2E test suite
- Security audit
- Load testing
- Staging deployment
- Production deployment
- Marketing website
```

### Post-Launch: Iterations
```
Phase 6 (Future):
- Job posting system
- Advanced matching algorithm
- Payment integration
- Review/rating system
- Mobile apps
- API for third-party integrations
```

---

## 💰 Cost Estimation

### Monthly Operating Costs (Estimated)
```
Supabase:
- Free tier: $0 (500MB database, 1GB bandwidth, 50MB storage)
- Pro tier: $25/month (8GB database, 250GB bandwidth, 100GB storage)
- Team tier: $599/month (when scaling)

Google Cloud Run:
- Free tier: 2 million requests/month
- Paid: ~$50-200/month depending on traffic

Domain & SSL:
- Domain: $12/year
- SSL: Free (Let's Encrypt)

Email Service (SendGrid/Resend):
- Free tier: 100 emails/day
- Paid: $15-50/month

Total Estimated Monthly Cost:
- Launch (low traffic): $40-70/month
- Growth (medium traffic): $150-300/month
- Scale (high traffic): $600-1000/month
🎯 Success Metrics (KPIs)
Launch Goals (First 3 Months)
100 linguist signups
50 agency signups
20 active connections
80% profile completion rate
< 5 second page load time
< 1% error rate
6-Month Goals
500 linguists
200 agencies
150 active connections
50+ successful project completions
4.5+ average rating
30% month-over-month growth
12-Month Goals
2000 linguists
500 agencies
1000 active connections
Revenue generation model implemented
Mobile app launched
API partnerships established
🛠️ Development Tools & Setup
Required Tools

bash
# Core
- Node.js 20+
- npm or pnpm
- Git
- VS Code (recommended)

# CLI Tools
- Supabase CLI
- Google Cloud CLI (gcloud)
- GitHub CLI (gh)

# VS Code Extensions
- ESLint
- Prettier
- Tailwind CSS IntelliSense
- TypeScript + JavaScript
- Supabase
Environment Variables

bash
# .env.local
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_anon_key
VITE_APP_URL=http://localhost:5173
VITE_GOOGLE_CLOUD_PROJECT=your_project_id
```

---

## 📝 Documentation Requirements

### Developer Documentation
- Architecture overview
- Setup guide
- Component library (Storybook)
- API documentation
- Database schema docs
- Deployment guide

### User Documentation
- Getting started guide
- Linguist onboarding
- Agency onboarding
- Best practices guide
- FAQ
- Video tutorials

---

## 🚨 Risk Mitigation

### Technical Risks
```
Risk: Data breach
Mitigation: RLS, encryption, security audits

Risk: Poor performance at scale
Mitigation: Caching, CDN, database optimization

Risk: Supabase downtime
Mitigation: Status page monitoring, backup plan

Risk: File storage costs
Mitigation: File size limits, compression, retention policies
```

### Business Risks
```
Risk: Low user adoption
Mitigation: Beta testing, user feedback, marketing

Risk: Competitor entry
Mitigation: Unique features, strong community, first-mover advantage

Risk: Regulatory changes
Mitigation: Legal consultation, privacy-first design
🎨 Design System
Color Palette

css
Primary (Blue): For linguists
- #2563eb (blue-600)
- #1e40af (blue-700)

Secondary (Green): For agencies
- #10b981 (emerald-500)
- #059669 (emerald-600)

Accent Colors:
- CIO: #2563eb (blue)
- CEO: #dc2626 (red)
- CHRO: #9333ea (purple)
- COO: #ea580c (orange)
- CFO: #10b981 (emerald)

Neutrals:
- #0f172a (slate-900)
- #1e293b (slate-800)
- #334155 (slate-700)
- #64748b (slate-500)
- #f1f5f9 (slate-100)
Typography

css
Font Family: Inter
Headings: 600-700 weight
Body: 400-500 weight
Small text: 300-400 weight

Sizes:
- 3xl: Section headers
- 2xl: Page titles
- xl: Card headers
- lg: Subheadings
- base: Body text
- sm: Helper text
- xs: Labels
📞 Support & Maintenance
Support Channels
In-app help center
Email support (support@linguamatch.com)
FAQ/Knowledge base
Community forum (future)
Maintenance Plan
Weekly security updates
Monthly feature releases
Quarterly major updates
24/7 uptime monitoring
Database backups (daily)
🎉 Launch Checklist
Pre-Launch
 All core features tested
 Security audit completed
 Privacy policy & terms published
 Marketing website live
 Email templates created
 Analytics configured
 Error monitoring setup
 Backup strategy in place
 Domain configured
 SSL certificates active
Launch Day
 Deploy to production
 Smoke tests passing
 Monitoring dashboards active
 Support channels ready
 Social media announcements
 Press release distributed
 Beta users invited
Post-Launch (Week 1)
 Monitor error rates
 Collect user feedback
 Fix critical bugs
 Adjust based on usage patterns
 Send welcome emails
 Schedule follow-up surveys
📚 Additional Resources
Learning Resources
Supabase Documentation
React Documentation
Tailwind CSS Documentation
TypeScript Handbook
Web Accessibility Guidelines (WCAG)
Community
GitHub Discussions
Discord server (future)
Twitter updates
Blog/changelog
🎯 NEXT STEPS
Immediate Actions:
Review & Approve Blueprint - Stakeholder sign-off
Set up Project Management - Create Jira/Linear board
Assemble Team - Assign roles (frontend, backend, design, QA)
Create Design Mockups - High-fidelity designs in Figma
Initialize Repository - Set up GitHub repo with structure
Configure Supabase - Create project, set up database
Kick off Phase 1 - Begin Week 1 development
This blueprint is comprehensive and ready for implementation. Let me know if you need any section expanded or modified!



Copied from: Converting vanilla AI studio app to React - Claude - <https://claude.ai/chat/5e956eaf-91b2-4825-90bc-d26eec511c89>
