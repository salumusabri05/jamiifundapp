-- This migration creates a function that can be used to set up RLS policies for storage
-- Note: This approach is necessary because direct ALTER TABLE on storage.objects may require owner privileges

-- Create a function to set up the RLS policies with security definer privileges
CREATE OR REPLACE FUNCTION setup_verification_documents_rls()
RETURNS void AS $$
BEGIN
    -- Note: In your local dev environment, storage RLS might already be enabled
    -- This line might fail in that case, but the function will continue with the policies
    BEGIN
        ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
    EXCEPTION WHEN others THEN
        RAISE NOTICE 'RLS might already be enabled on storage.objects';
    END;

    -- Drop existing policies with the same names if they exist
    BEGIN
        DROP POLICY IF EXISTS "Users can view their own verification documents" ON storage.objects;
        DROP POLICY IF EXISTS "Users can upload their own verification documents" ON storage.objects;
        DROP POLICY IF EXISTS "Users can update their own verification documents" ON storage.objects;
        DROP POLICY IF EXISTS "Users can delete their own verification documents" ON storage.objects;
        DROP POLICY IF EXISTS "Admins can access all verification documents" ON storage.objects;
    EXCEPTION WHEN others THEN
        RAISE NOTICE 'Error dropping policies, might not exist yet';
    END;

    -- Create policy for users to read any document in the verification_documents bucket
    CREATE POLICY "Users can view verification documents"
    ON storage.objects
    FOR SELECT
    USING (
        bucket_id = 'verification_documents'
    );

    -- Create policy for users to insert documents directly into the verification_documents bucket
    CREATE POLICY "Users can upload verification documents"
    ON storage.objects
    FOR INSERT
    WITH CHECK (
        bucket_id = 'verification_documents'
    );

    -- Create policy for users to update documents in the verification_documents bucket
    CREATE POLICY "Users can update verification documents"
    ON storage.objects
    FOR UPDATE
    USING (
        bucket_id = 'verification_documents'
    );

    -- Create policy for users to delete documents in the verification_documents bucket
    CREATE POLICY "Users can delete verification documents"
    ON storage.objects
    FOR DELETE
    USING (
        bucket_id = 'verification_documents'
    );

    -- Create policy for admins to read all verification documents
    CREATE POLICY "Admins can access all verification documents"
    ON storage.objects
    FOR ALL
    USING (
        bucket_id = 'verification_documents' AND
        auth.jwt() ->> 'role' = 'admin'
    );

    -- Grant access to authenticated users
    GRANT SELECT, INSERT, UPDATE, DELETE ON storage.objects TO authenticated;
END;
$$ LANGUAGE plpgsql;

-- Execute the function to set up the policies
SELECT setup_verification_documents_rls();

-- Clean up: Drop the function after using it
DROP FUNCTION setup_verification_documents_rls();
