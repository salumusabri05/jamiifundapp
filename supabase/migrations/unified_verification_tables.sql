-- Create unified verification tables

-- Create verifications table
CREATE TABLE IF NOT EXISTS verifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  status TEXT NOT NULL DEFAULT 'pending',
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
  is_organization BOOLEAN DEFAULT FALSE,
  organization_name TEXT,
  organization_reg_number TEXT,
  organization_address TEXT,
  organization_bank_account TEXT,
  organization_bank_name TEXT,
  organization_logo_url TEXT,
  organization_document_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Create verification members table for organization members
CREATE TABLE IF NOT EXISTS verification_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  id_document_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Set up RLS for verifications
ALTER TABLE verifications ENABLE ROW LEVEL SECURITY;

-- Users can read their own verification
CREATE POLICY "Users can view their own verification"
  ON verifications FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own verification
CREATE POLICY "Users can insert their own verification"
  ON verifications FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own verification
CREATE POLICY "Users can update their own verification"
  ON verifications FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Set up RLS for verification members
ALTER TABLE verification_members ENABLE ROW LEVEL SECURITY;

-- Users can view verification members if they can view the parent verification
CREATE POLICY "Users can view verification members they own"
  ON verification_members FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM verifications
    WHERE verifications.id = verification_members.verification_id
    AND verifications.user_id = auth.uid()
  ));

-- Users can insert verification members if they own the parent verification
CREATE POLICY "Users can insert verification members they own"
  ON verification_members FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM verifications
    WHERE verifications.id = verification_members.verification_id
    AND verifications.user_id = auth.uid()
  ));

-- Users can update verification members if they own the parent verification
CREATE POLICY "Users can update verification members they own"
  ON verification_members FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM verifications
    WHERE verifications.id = verification_members.verification_id
    AND verifications.user_id = auth.uid()
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM verifications
    WHERE verifications.id = verification_members.verification_id
    AND verifications.user_id = auth.uid()
  ));

-- Users can delete verification members if they own the parent verification
CREATE POLICY "Users can delete verification members they own"
  ON verification_members FOR DELETE
  USING (EXISTS (
    SELECT 1 FROM verifications
    WHERE verifications.id = verification_members.verification_id
    AND verifications.user_id = auth.uid()
  ));

-- Update campaigns policy to check verification status using the new verifications table
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'campaigns') THEN
        DROP POLICY IF EXISTS "Users can create campaigns" ON campaigns;
        
        CREATE POLICY "Users can create campaigns" 
        ON campaigns FOR INSERT 
        WITH CHECK (
            auth.uid() = created_by AND 
            EXISTS (
                SELECT 1 FROM verifications
                WHERE user_id = auth.uid() AND status = 'completed'
            )
        );
    END IF;
END $$;
