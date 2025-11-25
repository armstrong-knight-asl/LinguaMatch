-- LinguaMatch Row-Level Security Policies
-- Created: 2025-11-25

-- =====================================================
-- ENABLE RLS ON ALL TABLES
-- =====================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.linguist_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agency_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_postings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bulk_uploads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- USERS TABLE POLICIES
-- =====================================================

-- Users can read their own user record
CREATE POLICY "Users can view own user data"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own user record
CREATE POLICY "Users can update own user data"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

-- =====================================================
-- LINGUIST PROFILES POLICIES
-- =====================================================

-- Public linguist profiles visible to all authenticated users
CREATE POLICY "Public linguist profiles visible to authenticated users"
    ON public.linguist_profiles FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND (
            profile_visibility = 'public'
            OR (profile_visibility = 'verified_only' AND EXISTS (
                SELECT 1 FROM public.agency_profiles
                WHERE user_id = auth.uid()
                AND verification_status = 'verified'
            ))
            OR user_id = auth.uid()
        )
    );

-- Linguists can insert their own profile
CREATE POLICY "Linguists can create own profile"
    ON public.linguist_profiles FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- Linguists can update their own profile
CREATE POLICY "Linguists can update own profile"
    ON public.linguist_profiles FOR UPDATE
    USING (user_id = auth.uid());

-- Linguists can delete their own profile
CREATE POLICY "Linguists can delete own profile"
    ON public.linguist_profiles FOR DELETE
    USING (user_id = auth.uid());

-- =====================================================
-- AGENCY PROFILES POLICIES
-- =====================================================

-- Verified agencies visible to authenticated users
CREATE POLICY "Agencies visible to authenticated users"
    ON public.agency_profiles FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND (
            verification_status = 'verified'
            OR profile_visibility = 'public'
            OR user_id = auth.uid()
        )
    );

-- Agencies can insert their own profile
CREATE POLICY "Agencies can create own profile"
    ON public.agency_profiles FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- Agencies can update their own profile
CREATE POLICY "Agencies can update own profile"
    ON public.agency_profiles FOR UPDATE
    USING (user_id = auth.uid());

-- Agencies can delete their own profile
CREATE POLICY "Agencies can delete own profile"
    ON public.agency_profiles FOR DELETE
    USING (user_id = auth.uid());

-- =====================================================
-- CONNECTIONS POLICIES
-- =====================================================

-- Users can view connections they're part of
CREATE POLICY "Users can view their connections"
    ON public.connections FOR SELECT
    USING (
        linguist_id IN (
            SELECT id FROM public.linguist_profiles
            WHERE user_id = auth.uid()
        )
        OR agency_id IN (
            SELECT id FROM public.agency_profiles
            WHERE user_id = auth.uid()
        )
    );

-- Users can create connections
CREATE POLICY "Users can create connections"
    ON public.connections FOR INSERT
    WITH CHECK (
        (initiated_by = 'linguist' AND linguist_id IN (
            SELECT id FROM public.linguist_profiles
            WHERE user_id = auth.uid()
        ))
        OR (initiated_by = 'agency' AND agency_id IN (
            SELECT id FROM public.agency_profiles
            WHERE user_id = auth.uid()
        ))
    );

-- Users can update connections they're part of
CREATE POLICY "Users can update their connections"
    ON public.connections FOR UPDATE
    USING (
        linguist_id IN (
            SELECT id FROM public.linguist_profiles
            WHERE user_id = auth.uid()
        )
        OR agency_id IN (
            SELECT id FROM public.agency_profiles
            WHERE user_id = auth.uid()
        )
    );

-- =====================================================
-- DOCUMENTS POLICIES
-- =====================================================

-- Users can view their own documents
CREATE POLICY "Users can view own documents"
    ON public.documents FOR SELECT
    USING (owner_id = auth.uid());

-- Connected parties can view shared documents
CREATE POLICY "Connected parties view shared documents"
    ON public.documents FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND (
            visibility = 'public'
            OR (visibility = 'connections_only' AND (
                owner_id IN (
                    -- Check if viewer is a linguist viewing agency documents
                    SELECT c.agency_id
                    FROM public.connections c
                    JOIN public.linguist_profiles lp ON c.linguist_id = lp.id
                    WHERE lp.user_id = auth.uid()
                    AND c.status = 'accepted'
                    UNION
                    -- Check if viewer is an agency viewing linguist documents
                    SELECT c.linguist_id
                    FROM public.connections c
                    JOIN public.agency_profiles ap ON c.agency_id = ap.id
                    WHERE ap.user_id = auth.uid()
                    AND c.status = 'accepted'
                )
            ))
            OR (visibility = 'verified_agencies' AND EXISTS (
                SELECT 1 FROM public.agency_profiles
                WHERE user_id = auth.uid()
                AND verification_status = 'verified'
            ))
        )
    );

-- Users can insert their own documents
CREATE POLICY "Users can upload own documents"
    ON public.documents FOR INSERT
    WITH CHECK (owner_id = auth.uid());

-- Users can update their own documents
CREATE POLICY "Users can update own documents"
    ON public.documents FOR UPDATE
    USING (owner_id = auth.uid());

-- Users can delete their own documents
CREATE POLICY "Users can delete own documents"
    ON public.documents FOR DELETE
    USING (owner_id = auth.uid());

-- =====================================================
-- CONVERSATIONS POLICIES
-- =====================================================

-- Users can view conversations they're part of
CREATE POLICY "Users can view their conversations"
    ON public.conversations FOR SELECT
    USING (
        linguist_id IN (
            SELECT id FROM public.linguist_profiles
            WHERE user_id = auth.uid()
        )
        OR agency_id IN (
            SELECT id FROM public.agency_profiles
            WHERE user_id = auth.uid()
        )
    );

-- Users can create conversations (system will handle this)
CREATE POLICY "Users can create conversations"
    ON public.conversations FOR INSERT
    WITH CHECK (
        linguist_id IN (
            SELECT id FROM public.linguist_profiles
            WHERE user_id = auth.uid()
        )
        OR agency_id IN (
            SELECT id FROM public.agency_profiles
            WHERE user_id = auth.uid()
        )
    );

-- Users can update their conversations
CREATE POLICY "Users can update their conversations"
    ON public.conversations FOR UPDATE
    USING (
        linguist_id IN (
            SELECT id FROM public.linguist_profiles
            WHERE user_id = auth.uid()
        )
        OR agency_id IN (
            SELECT id FROM public.agency_profiles
            WHERE user_id = auth.uid()
        )
    );

-- =====================================================
-- MESSAGES POLICIES
-- =====================================================

-- Users can view messages in their conversations
CREATE POLICY "Users can view messages in their conversations"
    ON public.messages FOR SELECT
    USING (
        conversation_id IN (
            SELECT id FROM public.conversations
            WHERE linguist_id IN (
                SELECT id FROM public.linguist_profiles
                WHERE user_id = auth.uid()
            )
            OR agency_id IN (
                SELECT id FROM public.agency_profiles
                WHERE user_id = auth.uid()
            )
        )
    );

-- Users can send messages in their conversations
CREATE POLICY "Users can send messages in their conversations"
    ON public.messages FOR INSERT
    WITH CHECK (
        sender_id = auth.uid()
        AND conversation_id IN (
            SELECT id FROM public.conversations
            WHERE linguist_id IN (
                SELECT id FROM public.linguist_profiles
                WHERE user_id = auth.uid()
            )
            OR agency_id IN (
                SELECT id FROM public.agency_profiles
                WHERE user_id = auth.uid()
            )
        )
    );

-- Users can update their own messages (for read receipts)
CREATE POLICY "Users can update messages in their conversations"
    ON public.messages FOR UPDATE
    USING (
        conversation_id IN (
            SELECT id FROM public.conversations
            WHERE linguist_id IN (
                SELECT id FROM public.linguist_profiles
                WHERE user_id = auth.uid()
            )
            OR agency_id IN (
                SELECT id FROM public.agency_profiles
                WHERE user_id = auth.uid()
            )
        )
    );

-- =====================================================
-- JOB POSTINGS POLICIES
-- =====================================================

-- Public job postings visible to all authenticated users
CREATE POLICY "Active job postings visible to authenticated users"
    ON public.job_postings FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND (status = 'active' OR agency_id IN (
            SELECT id FROM public.agency_profiles
            WHERE user_id = auth.uid()
        ))
    );

-- Agencies can create job postings
CREATE POLICY "Agencies can create job postings"
    ON public.job_postings FOR INSERT
    WITH CHECK (
        agency_id IN (
            SELECT id FROM public.agency_profiles
            WHERE user_id = auth.uid()
        )
    );

-- Agencies can update their own job postings
CREATE POLICY "Agencies can update own job postings"
    ON public.job_postings FOR UPDATE
    USING (
        agency_id IN (
            SELECT id FROM public.agency_profiles
            WHERE user_id = auth.uid()
        )
    );

-- Agencies can delete their own job postings
CREATE POLICY "Agencies can delete own job postings"
    ON public.job_postings FOR DELETE
    USING (
        agency_id IN (
            SELECT id FROM public.agency_profiles
            WHERE user_id = auth.uid()
        )
    );

-- =====================================================
-- JOB APPLICATIONS POLICIES
-- =====================================================

-- Linguists can view their own applications
-- Agencies can view applications to their jobs
CREATE POLICY "Users can view relevant job applications"
    ON public.job_applications FOR SELECT
    USING (
        linguist_id IN (
            SELECT id FROM public.linguist_profiles
            WHERE user_id = auth.uid()
        )
        OR job_id IN (
            SELECT id FROM public.job_postings
            WHERE agency_id IN (
                SELECT id FROM public.agency_profiles
                WHERE user_id = auth.uid()
            )
        )
    );

-- Linguists can create job applications
CREATE POLICY "Linguists can create job applications"
    ON public.job_applications FOR INSERT
    WITH CHECK (
        linguist_id IN (
            SELECT id FROM public.linguist_profiles
            WHERE user_id = auth.uid()
        )
    );

-- Linguists can update their own applications
CREATE POLICY "Linguists can update own job applications"
    ON public.job_applications FOR UPDATE
    USING (
        linguist_id IN (
            SELECT id FROM public.linguist_profiles
            WHERE user_id = auth.uid()
        )
    );

-- =====================================================
-- REVIEWS POLICIES
-- =====================================================

-- Users can view reviews about themselves or that they wrote
CREATE POLICY "Users can view relevant reviews"
    ON public.reviews FOR SELECT
    USING (
        auth.role() = 'authenticated'
        AND (
            status = 'published'
            OR reviewer_id = auth.uid()
            OR reviewee_id = auth.uid()
        )
    );

-- Users can create reviews for their connections
CREATE POLICY "Users can create reviews"
    ON public.reviews FOR INSERT
    WITH CHECK (reviewer_id = auth.uid());

-- Reviewees can respond to reviews
CREATE POLICY "Reviewees can update reviews (respond)"
    ON public.reviews FOR UPDATE
    USING (reviewee_id = auth.uid());

-- =====================================================
-- BULK UPLOADS POLICIES
-- =====================================================

-- Users can view their own bulk uploads
CREATE POLICY "Users can view own bulk uploads"
    ON public.bulk_uploads FOR SELECT
    USING (uploaded_by = auth.uid());

-- Users can create bulk uploads
CREATE POLICY "Users can create bulk uploads"
    ON public.bulk_uploads FOR INSERT
    WITH CHECK (uploaded_by = auth.uid());

-- Users can update their own bulk uploads
CREATE POLICY "Users can update own bulk uploads"
    ON public.bulk_uploads FOR UPDATE
    USING (uploaded_by = auth.uid());

-- =====================================================
-- NOTIFICATIONS POLICIES
-- =====================================================

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications"
    ON public.notifications FOR SELECT
    USING (user_id = auth.uid());

-- System can create notifications (service role)
CREATE POLICY "System can create notifications"
    ON public.notifications FOR INSERT
    WITH CHECK (true);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
    ON public.notifications FOR UPDATE
    USING (user_id = auth.uid());

-- Users can delete their own notifications
CREATE POLICY "Users can delete own notifications"
    ON public.notifications FOR DELETE
    USING (user_id = auth.uid());
