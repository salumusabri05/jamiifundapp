-- Create Row Level Security Policies for the verification_members table
-- Enable RLS on the table
ALTER TABLE public.verification_members ENABLE ROW LEVEL SECURITY;

-- Create policy for users to read their members via verification foreign key
CREATE POLICY "Users can view their own verification members"
ON public.verification_members
FOR SELECT
USING (
    verification_id IN (
        SELECT id FROM public.verifications 
        WHERE user_id = auth.uid()
    )
);

-- Create policy for users to insert members to their own verification
CREATE POLICY "Users can create their own verification members"
ON public.verification_members
FOR INSERT
WITH CHECK (
    verification_id IN (
        SELECT id FROM public.verifications 
        WHERE user_id = auth.uid()
    )
);

-- Create policy for users to update their own verification members
CREATE POLICY "Users can update their own verification members"
ON public.verification_members
FOR UPDATE
USING (
    verification_id IN (
        SELECT id FROM public.verifications 
        WHERE user_id = auth.uid()
    )
);

-- Create policy for users to delete their own verification members
CREATE POLICY "Users can delete their own verification members"
ON public.verification_members
FOR DELETE
USING (
    verification_id IN (
        SELECT id FROM public.verifications 
        WHERE user_id = auth.uid()
    )
);

-- Create policy for admins to read all records
CREATE POLICY "Admins can view all verification members"
ON public.verification_members
FOR SELECT
USING (auth.jwt() ->> 'role' = 'admin');

-- Create policy for admins to update all records
CREATE POLICY "Admins can update all verification members"
ON public.verification_members
FOR ALL
USING (auth.jwt() ->> 'role' = 'admin');

-- Grant access to authenticated users
GRANT SELECT, INSERT, UPDATE, DELETE ON public.verification_members TO authenticated;
