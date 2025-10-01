-- Create storage bucket for verification documents
INSERT INTO storage.buckets (id, name)
VALUES ('verification_documents', 'verification_documents')
ON CONFLICT (id) DO NOTHING;

-- Set bucket to public (optional - if you want public access without authentication)
-- If you want to restrict access only through RLS policies, comment this out
UPDATE storage.buckets
SET public = false
WHERE id = 'verification_documents';
