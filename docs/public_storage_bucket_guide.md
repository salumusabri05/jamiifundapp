# Public Storage Bucket Guide

## Overview
The verification documents storage bucket has already been configured as a public bucket in Supabase with simplified access controls. This means:

1. Files can be uploaded directly to the bucket root without requiring user-specific folders
2. Uploaded files can be accessed by anyone with the URL (public access)
3. Only authenticated users can upload files to the bucket

## Storage Structure
Files are uploaded directly to the root of the `verification_documents` bucket. File uniqueness is ensured by:
- Including the user ID in the filename (e.g., `id_user123_timestamp.jpg`)
- Adding timestamps to prevent filename collisions

## How It Works

### Bucket Configuration
- The bucket is already configured as public in Supabase
- RLS policies allow anyone to read from the bucket
- RLS policies restrict write operations to authenticated users only

### File Upload Process
1. User authentication is verified
2. Filename is generated with user ID and timestamp
3. File is uploaded directly to bucket root
4. Public URL is generated for the file

### Code Example
```dart
// Generate unique filename with user ID embedded
final timestamp = DateTime.now().millisecondsSinceEpoch;
final fileName = 'id_${userId}_${timestamp}.jpg';

// Upload directly to bucket root
await supabaseClient.storage
    .from('verification_documents')
    .uploadBinary(
      fileName, 
      bytes,
      fileOptions: FileOptions(
        contentType: 'image/jpeg',
        upsert: true
      )
    );

// Get public URL
final fileUrl = supabaseClient.storage
    .from('verification_documents')
    .getPublicUrl(fileName);
```

## Security Considerations
- **User ID Embedded**: Each filename contains the user ID, maintaining a connection between files and users
- **Public Access**: All files in the bucket can be viewed by anyone with the URL
- **Write Protection**: Only authenticated users can upload files

## Tools
- **RLS Tester**: Use the RLS Tester tool in the app to:
  - Test bucket permissions
  - Test direct uploads to the public bucket

## Important Notes
- The bucket is **already created** in Supabase and configured as public
- No bucket creation or permission changes are needed
- The app directly uses the existing bucket configuration
- The simplified storage approach embeds user identification in filenames for traceability
- Files are uploaded directly to the bucket root without nested folder structure
