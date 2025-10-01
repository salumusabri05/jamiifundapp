import 'package:flutter/material.dart';
import 'package:jamiifund/services/supabase_client.dart';

class BucketResult {
  final bool success;
  final String message;
  
  BucketResult({required this.success, required this.message});
}

class StorageBucketSetupHelper {
  // Method to check if a bucket exists (no longer creates buckets since they're already set up in Supabase)
  Future<BucketResult> createBucket(String bucketName) async {
    try {
      // Check if bucket exists 
      final buckets = await SupabaseService.client.storage.listBuckets();
      if (buckets.any((bucket) => bucket.name == bucketName)) {
        return BucketResult(
          success: true, 
          message: 'Bucket "$bucketName" already exists in Supabase and is configured as public.'
        );
      }
      
      // If we get here, the bucket doesn't exist
      return BucketResult(
        success: false, 
        message: 'Bucket "$bucketName" does not exist in Supabase. Please check your Supabase configuration.'
      );
    } catch (e) {
      return BucketResult(
        success: false, 
        message: 'Error checking bucket: $e'
      );
    }
  }

  // Run this method after successful login to ensure all required buckets exist
  static Future<void> ensureBucketsExist(BuildContext? context) async {
    try {
      await SupabaseService.ensureRequiredBuckets();
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage buckets verified'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error setting up storage buckets: $e');
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting up storage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Show an error dialog for missing buckets with options to fix
  static Future<void> showMissingBucketDialog(BuildContext context, String bucketName) async {
    // Check current user role to see if they likely have permissions
    String roleInfo = '';
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final session = SupabaseService.client.auth.currentSession;
        if (session != null) {
          final tokenPreview = session.accessToken.substring(0, 20) + '...'; // Just show a part to avoid exposing the full token
          roleInfo = 'Current user: ${user.email}\nUser ID: ${user.id}\nToken: $tokenPreview\n';
        } else {
          roleInfo = 'User authenticated but no active session found.\n';
        }
      } else {
        roleInfo = 'Not authenticated. You may not have permission to create buckets.\n';
      }
    } catch (e) {
      roleInfo = 'Error getting auth info: $e\n';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Setup Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('The required storage bucket "$bucketName" is missing.'),
            const SizedBox(height: 8),
            Text(
              'This is needed for file uploads. Without this bucket, document uploads will fail.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              roleInfo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            const Text('Would you like to create it now?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Creating bucket...'),
                    ],
                  ),
                ),
              );
              
              try {
                final success = await SupabaseService.validateStorageBucket(bucketName);
                
                if (context.mounted) {
                  Navigator.pop(context); // Remove loading dialog
                  
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Storage bucket created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create storage bucket'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Remove loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error creating bucket: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Create Bucket'),
          ),
        ],
      ),
    );
  }
}
