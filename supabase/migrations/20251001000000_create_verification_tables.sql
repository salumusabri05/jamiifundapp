-- Create the verification-related tables
-- Create the verifications table for unified verification approach
CREATE TABLE IF NOT EXISTS public.verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    status TEXT NOT NULL DEFAULT 'pending',
    
    -- Personal KYC data
    full_name TEXT,
    date_of_birth TEXT,
    national_id TEXT,
    address TEXT,
    phone TEXT,
    email TEXT,
    selfie_url TEXT,
    id_document_url TEXT,
    bank_account TEXT,
    bank_name TEXT,
    
    -- Organization data
    is_organization BOOLEAN NOT NULL DEFAULT FALSE,
    organization_name TEXT,
    organization_reg_number TEXT,
    organization_address TEXT,
    organization_bank_account TEXT,
    organization_bank_name TEXT,
    organization_logo_url TEXT,
    organization_document_url TEXT,
    
    -- Admin fields
    rejection_reason TEXT,
    admin_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT fk_user FOREIGN KEY (user_id)
        REFERENCES auth.users (id) ON DELETE CASCADE
);

-- Create the verification_members table for organization members
CREATE TABLE IF NOT EXISTS public.verification_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    verification_id UUID NOT NULL,
    full_name TEXT NOT NULL,
    position TEXT,
    national_id TEXT,
    phone TEXT,
    email TEXT,
    photo_url TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT fk_verification FOREIGN KEY (verification_id)
        REFERENCES public.verifications (id) ON DELETE CASCADE
);

-- Create the verification_requests table (legacy approach)
CREATE TABLE IF NOT EXISTS public.verification_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    document_type TEXT,
    id_url TEXT,
    status TEXT DEFAULT 'pending',
    notes TEXT,
    rejection_reason TEXT,
    full_name TEXT,
    phone_number TEXT,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Create index on user_id for better performance
CREATE INDEX IF NOT EXISTS idx_verifications_user_id ON public.verifications (user_id);
CREATE INDEX IF NOT EXISTS idx_verification_requests_user_id ON public.verification_requests (user_id);
CREATE INDEX IF NOT EXISTS idx_verification_members_verification_id ON public.verification_members (verification_id);

-- Make sure we have a storage bucket for verification documents
INSERT INTO storage.buckets (id, name) 
VALUES ('verification_documents', 'verification_documents') 
ON CONFLICT (id) DO NOTHING;
