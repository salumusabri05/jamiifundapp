# Database Migration Guide for JamiiFund

You're encountering database errors because the required tables don't exist in your Supabase database. Here's how to fix this:

## Option 1: Run the Migrations Using Supabase CLI

If you have the Supabase CLI installed, you can run:

```bash
supabase db push
```

This will apply all migration files in the `supabase/migrations` directory.

## Option 2: Create the Tables Manually

1. Log in to your Supabase dashboard
2. Go to the SQL Editor
3. Copy and paste the following SQL:

```sql
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
```

4. Click "Run" to execute the SQL

## Optional: Create the verification_requests Table

If you also need the older verification_requests table:

```sql
-- Create verification_requests table
CREATE TABLE verification_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  full_name TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  address TEXT NOT NULL,
  id_document_url TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  rejection_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Set up RLS (Row Level Security) for verification_requests
ALTER TABLE verification_requests ENABLE ROW LEVEL SECURITY;

-- Users can read their own verification requests
CREATE POLICY "Users can view their own verification requests"
  ON verification_requests FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own verification requests
CREATE POLICY "Users can insert their own verification requests"
  ON verification_requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own verification requests (only certain fields)
CREATE POLICY "Users can update their own verification requests"
  ON verification_requests FOR UPDATE
  USING (auth.uid() = user_id AND status = 'rejected')
  WITH CHECK (auth.uid() = user_id AND status = 'pending');
```

After running these SQL commands, your app should work properly with the verification system.
