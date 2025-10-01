-- Create Row Level Security Policies for the verification_requests table
-- Enable RLS on the table
ALTER TABLE public.verification_requests ENABLE ROW LEVEL SECURITY;

-- Create policy for users to read their own records only
CREATE POLICY "Users can view their own verification requests"
ON public.verification_requests
FOR SELECT
USING (auth.uid() = user_id);

-- Create policy for users to insert their own records only
CREATE POLICY "Users can create their own verification requests"
ON public.verification_requests
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Create policy for users to update their own records only
CREATE POLICY "Users can update their own verification requests"
ON public.verification_requests
FOR UPDATE
USING (auth.uid() = user_id);

-- Create policy for admins to read all records
CREATE POLICY "Admins can view all verification requests"
ON public.verification_requests
FOR SELECT
USING (auth.jwt() ->> 'role' = 'admin');

-- Create policy for admins to update all records
CREATE POLICY "Admins can update all verification requests"
ON public.verification_requests
FOR UPDATE
USING (auth.jwt() ->> 'role' = 'admin');

-- Grant access to authenticated users
GRANT SELECT, INSERT, UPDATE ON public.verification_requests TO authenticated;
