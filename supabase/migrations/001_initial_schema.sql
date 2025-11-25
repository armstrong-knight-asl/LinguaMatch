-- LinguaMatch Initial Database Schema
-- Created: 2025-11-25

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    user_type TEXT NOT NULL CHECK (user_type IN ('linguist', 'agency')),
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ,
    profile_completed BOOLEAN DEFAULT FALSE,
    verification_status TEXT DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected'))
);

-- Linguist Profiles
CREATE TABLE public.linguist_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
    profile_visibility TEXT DEFAULT 'public' CHECK (profile_visibility IN ('public', 'private', 'verified_only')),

    -- Personal Information
    display_name TEXT,
    professional_title TEXT,
    profile_photo_url TEXT,
    bio TEXT,

    -- Language Pairs
    source_languages TEXT[],
    target_languages TEXT[],
    language_pairs JSONB[],

    -- Professional Details (CIO/CEO/CHRO/COO/CFO structure)
    cio_data JSONB, -- Front desk, contact, location
    ceo_data JSONB, -- Legal entity, business stats
    chro_data JSONB, -- Background, education, certifications
    coo_data JSONB, -- Operations, logistics, scheduling
    cfo_data JSONB, -- Rates, payment terms, invoicing

    -- Specializations
    service_types TEXT[], -- ['medical', 'legal', 'conference', 'consecutive']
    industries TEXT[], -- ['healthcare', 'legal', 'education']
    certifications JSONB[],
    education JSONB[],

    -- Availability
    available_for_hire BOOLEAN DEFAULT TRUE,
    work_modes TEXT[], -- ['remote', 'on-site', 'hybrid']
    timezone TEXT,
    standard_hours JSONB,

    -- Metrics
    jobs_completed INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    response_time_hours DECIMAL(5,2),
    profile_views INTEGER DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_active TIMESTAMPTZ
);

-- Agency Profiles
CREATE TABLE public.agency_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
    profile_visibility TEXT DEFAULT 'public' CHECK (profile_visibility IN ('public', 'private')),

    -- Company Information
    company_name TEXT,
    company_logo_url TEXT,
    company_type TEXT CHECK (company_type IN ('agency', 'enterprise', 'government', 'nonprofit')),
    description TEXT,
    founded_year INTEGER,
    company_size TEXT,

    -- Contact & Location
    primary_contact JSONB,
    headquarters_address JSONB,
    service_regions TEXT[],
    website TEXT,
    social_links JSONB,

    -- Business Details
    business_license_number TEXT,
    tax_id_available BOOLEAN DEFAULT FALSE,
    incorporation_state TEXT,
    insurance_coverage JSONB,

    -- Service Requirements
    languages_needed TEXT[],
    industries_served TEXT[],
    typical_project_types TEXT[],
    volume_per_month TEXT,

    -- Payment & Terms
    payment_terms JSONB,
    rate_ranges JSONB,
    preferred_payment_methods TEXT[],

    -- Metrics
    active_linguists INTEGER DEFAULT 0,
    projects_posted INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    response_time_hours DECIMAL(5,2),

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_active TIMESTAMPTZ
);

-- Connections (Matching Table)
CREATE TABLE public.connections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    linguist_id UUID NOT NULL REFERENCES public.linguist_profiles(id) ON DELETE CASCADE,
    agency_id UUID NOT NULL REFERENCES public.agency_profiles(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
    initiated_by TEXT NOT NULL CHECK (initiated_by IN ('linguist', 'agency')),
    connection_type TEXT NOT NULL CHECK (connection_type IN ('inquiry', 'invitation', 'application')),
    message TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    responded_at TIMESTAMPTZ,

    UNIQUE(linguist_id, agency_id)
);

-- Documents
CREATE TABLE public.documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    owner_type TEXT NOT NULL CHECK (owner_type IN ('linguist', 'agency')),
    document_type TEXT NOT NULL CHECK (document_type IN ('resume', 'certificate', 'license', 'insurance', 'contract', 'w9', 'business_license', 'other')),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER,
    mime_type TEXT,
    verification_status TEXT DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    verified_by UUID REFERENCES public.users(id),
    verified_at TIMESTAMPTZ,
    visibility TEXT DEFAULT 'private' CHECK (visibility IN ('private', 'connections_only', 'verified_agencies', 'public')),
    expiration_date DATE,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Conversations
CREATE TABLE public.conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    linguist_id UUID NOT NULL REFERENCES public.linguist_profiles(id) ON DELETE CASCADE,
    agency_id UUID NOT NULL REFERENCES public.agency_profiles(id) ON DELETE CASCADE,
    connection_id UUID REFERENCES public.connections(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'archived', 'blocked')),
    last_message_at TIMESTAMPTZ,
    unread_count_linguist INTEGER DEFAULT 0,
    unread_count_agency INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Messages
CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    sender_type TEXT NOT NULL CHECK (sender_type IN ('linguist', 'agency')),
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'file', 'system')),
    content TEXT,
    attachments JSONB[],
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Job Postings (Future Enhancement)
CREATE TABLE public.job_postings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agency_id UUID NOT NULL REFERENCES public.agency_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    language_pair JSONB,
    service_type TEXT,
    work_mode TEXT CHECK (work_mode IN ('remote', 'on-site', 'hybrid')),
    location JSONB,
    start_date DATE,
    duration TEXT,
    rate_range JSONB,
    requirements JSONB,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'filled', 'cancelled')),
    applications_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ
);

-- Job Applications (Future Enhancement)
CREATE TABLE public.job_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES public.job_postings(id) ON DELETE CASCADE,
    linguist_id UUID NOT NULL REFERENCES public.linguist_profiles(id) ON DELETE CASCADE,
    cover_letter TEXT,
    proposed_rate DECIMAL(10,2),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'shortlisted', 'accepted', 'rejected', 'withdrawn')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reviews
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reviewer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    reviewer_type TEXT NOT NULL CHECK (reviewer_type IN ('linguist', 'agency')),
    reviewee_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    reviewee_type TEXT NOT NULL CHECK (reviewee_type IN ('linguist', 'agency')),
    connection_id UUID REFERENCES public.connections(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    categories JSONB,
    response TEXT,
    status TEXT DEFAULT 'published' CHECK (status IN ('published', 'flagged', 'hidden')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bulk Uploads
CREATE TABLE public.bulk_uploads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    uploaded_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    upload_type TEXT NOT NULL CHECK (upload_type IN ('linguists', 'agencies')),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    total_records INTEGER DEFAULT 0,
    processed_records INTEGER DEFAULT 0,
    successful_records INTEGER DEFAULT 0,
    failed_records INTEGER DEFAULT 0,
    error_log JSONB,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Notifications
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('connection_request', 'message', 'document_verified', 'profile_view', 'review_received', 'system')),
    title TEXT NOT NULL,
    content TEXT,
    action_url TEXT,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================

-- Performance Indexes
CREATE INDEX idx_linguist_languages ON public.linguist_profiles USING GIN(source_languages);
CREATE INDEX idx_linguist_target_languages ON public.linguist_profiles USING GIN(target_languages);
CREATE INDEX idx_linguist_available ON public.linguist_profiles(available_for_hire) WHERE available_for_hire = true;
CREATE INDEX idx_agency_languages ON public.agency_profiles USING GIN(languages_needed);
CREATE INDEX idx_connections_status ON public.connections(status, created_at DESC);
CREATE INDEX idx_messages_conversation ON public.messages(conversation_id, created_at DESC);
CREATE INDEX idx_notifications_user ON public.notifications(user_id, read_at, created_at DESC);
CREATE INDEX idx_documents_owner ON public.documents(owner_id, owner_type);

-- Full-text Search Indexes
CREATE INDEX idx_linguist_search ON public.linguist_profiles USING GIN(
    to_tsvector('english', COALESCE(display_name, '') || ' ' || COALESCE(bio, ''))
);
CREATE INDEX idx_agency_search ON public.agency_profiles USING GIN(
    to_tsvector('english', COALESCE(company_name, '') || ' ' || COALESCE(description, ''))
);

-- =====================================================
-- TRIGGERS FOR UPDATED_AT
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_users
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_linguist_profiles
    BEFORE UPDATE ON public.linguist_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_agency_profiles
    BEFORE UPDATE ON public.agency_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_connections
    BEFORE UPDATE ON public.connections
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_documents
    BEFORE UPDATE ON public.documents
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_job_applications
    BEFORE UPDATE ON public.job_applications
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
