# Fixing "Bucket does not exist" Error in JamiiFund App

If you're encountering the "Bucket does not exist: verification_documents" error when trying to upload documents for verification, follow these steps to resolve the issue:

## Option 1: Use the Built-in Diagnostic Tools

1. Go to the **Verification Screen** in the app
2. Tap the **Diagnostics** icon (wrench/tool icon) in the top-right corner
3. In the diagnostics dialog, select **Create Missing Bucket**
4. After the bucket is created, try uploading your documents again

## Option 2: Use the RLS Tester

1. Go to the **Verification Screen**
2. Tap the **Diagnostics** icon in the top-right corner
3. Select **Test RLS Permissions**
4. In the RLS Tester screen, tap the **Create Verification Bucket** button
5. Return to the verification screen and try uploading again

## Option 3: Run Migration Files (for Developers)

If you have access to the database:

1. Ensure the migration file `20251001000004_create_verification_documents_bucket.sql` is applied
2. Also ensure `20251001000002_verification_documents_bucket_rls.sql` is applied to set proper permissions
3. Restart the app and try again

## Troubleshooting

If you're still encountering issues:

1. Check if you're properly authenticated (signed in)
2. Use the **Test RLS Permissions** option to verify your access rights
3. Use the **Check Storage Permissions** option to diagnose permission issues

For administrators, make sure the Supabase project has storage enabled and that the SQL migration files have been applied correctly to create the bucket and set up the proper RLS policies.
