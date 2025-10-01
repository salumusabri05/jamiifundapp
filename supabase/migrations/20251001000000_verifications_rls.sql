-- Create Row Level Security Policies for the verifications table
-- Enable RLS on the table
ALTER TABLE verifications ENABLE ROW LEVEL SECURITY;

-- Create policy for users to read their own records only
CREATE POLICY "Users can view their own verifications"
ON public.verifications
FOR SELECT
USING (auth.uid() = user_id);

-- Create policy for users to insert their own records only
CREATE POLICY "Users can create their own verifications"
ON public.verifications
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Create policy for users to update their own records only
CREATE POLICY "Users can update their own verifications"
ON public.verifications
FOR UPDATE
USING (auth.uid() = user_id);

-- Create policy for admins to read all records
CREATE POLICY "Admins can view all verifications"
ON public.verifications
FOR SELECT
USING (auth.jwt() ->> 'role' = 'admin');

-- Create policy for admins to update all records
CREATE POLICY "Admins can update all verifications"
ON public.verifications
FOR UPDATE
USING (auth.jwt() ->> 'role' = 'admin');

-- Grant access to authenticated users
GRANT SELECT, INSERT, UPDATE ON public.verifications TO authenticated;
