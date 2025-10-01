# Supabase Database Migrations

This directory contains SQL migration files for setting up the database schema and RLS policies.

## Migration Files Order

Apply the migrations in the following order:

1. **20251001000000_create_verification_tables.sql** - Creates the main tables for verification
2. **20251001000000_verifications_rls.sql** - Adds RLS policies for the verifications table
3. **20251001000001_verification_members_rls.sql** - Adds RLS policies for verification members table
4. **20251001000002_verification_documents_bucket_rls.sql** - Adds RLS policies for storage access
5. **20251001000003_verification_requests_rls.sql** - Adds RLS policies for legacy verification requests table

## How to Apply Migrations

You can apply these migrations using the Supabase CLI or through the Supabase dashboard:

### Using Supabase CLI:

```bash
supabase db push
```

### Using Supabase Dashboard:

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy the contents of each migration file
4. Paste and execute them in order

## Row Level Security (RLS) Policies

These migrations set up the following RLS policies:

1. **User Policies**:
   - Users can view/create/update their own verifications
   - Users can view/create/update/delete members of their own verifications
   - Users can view/upload/update/delete their own verification documents

2. **Admin Policies**:
   - Admins can view/update all verifications
   - Admins can view/update/delete all verification members
   - Admins can access all verification documents

To make a user an admin, you'll need to set the 'role' claim in their JWT to 'admin'.

## Storage Buckets

The migrations also create a storage bucket named 'verification_documents' for storing ID cards and other verification documents.

## Troubleshooting

If you encounter errors like "relation does not exist", make sure you've applied the migrations in the correct order - tables must be created before RLS policies can be added to them.
