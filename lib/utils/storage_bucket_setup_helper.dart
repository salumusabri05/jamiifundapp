import 'package:flutter/material.dart';
import 'package:jamiifund/services/supabase_client.dart';

class BucketResult {
  final bool success;
  final String message;
  
  BucketResult({required this.success, required this.message});
}

class StorageBucketSetupHelper {
  // Method to create a bucket with proper error handling
  Future<BucketResult> createBucket(String bucketName) async {
    try {
      // First check if bucket already exists to avoid errors
      final buckets = await SupabaseService.client.storage.listBuckets();
      if (buckets.any((bucket) => bucket.name == bucketName)) {
        return BucketResult(
          success: true, 
          message: 'Bucket "$bucketName" already exists, no need to create it.'
        );
      }
      
      // Create the bucket if it doesn't exist
      await SupabaseService.client.storage.createBucket(bucketName);
      
      print('Bucket created successfully');
      
      // Verify that the bucket now exists
      final updatedBuckets = await SupabaseService.client.storage.listBuckets();
      if (updatedBuckets.any((bucket) => bucket.name == bucketName)) {
        return BucketResult(
          success: true, 
          message: 'Bucket "$bucketName" created successfully.'
        );
      } else {
        return BucketResult(
          success: false, 
          message: 'Bucket creation API call succeeded but bucket not found in list. This may indicate an RLS permission issue.'
        );
      }
    } catch (e) {
      return BucketResult(
        success: false, 
        message: 'Error creating bucket: $e'
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
