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

-- Create payment_methods table
CREATE TABLE payment_methods (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  type TEXT NOT NULL,
  account_number TEXT NOT NULL,
  account_name TEXT NOT NULL,
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

-- Set up RLS for payment_methods
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;

-- Users can read their own payment methods
CREATE POLICY "Users can view their own payment methods"
  ON payment_methods FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own payment methods
CREATE POLICY "Users can insert their own payment methods"
  ON payment_methods FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own payment methods
CREATE POLICY "Users can update their own payment methods"
  ON payment_methods FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Add a verification_status column to the campaigns table if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'campaigns') THEN
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'campaigns' AND column_name = 'verification_required') THEN
            ALTER TABLE campaigns ADD COLUMN verification_required BOOLEAN DEFAULT true;
        END IF;
    END IF;
END $$;

-- Update campaigns policy to check verification status
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'campaigns') THEN
        DROP POLICY IF EXISTS "Users can create campaigns" ON campaigns;
        
        CREATE POLICY "Users can create campaigns" 
        ON campaigns FOR INSERT 
        WITH CHECK (
            auth.uid() = creator_id AND 
            EXISTS (
                SELECT 1 FROM verification_requests
                WHERE user_id = auth.uid() AND status = 'approved'
            )
        );
    END IF;
END $$;
