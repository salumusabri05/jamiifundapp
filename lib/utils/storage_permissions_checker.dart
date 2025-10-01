import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoragePermissionsChecker {
  static const String _testBucketName = 'verification_documents';
  
  // Test storage permissions and provide detailed error info
  static Future<StoragePermissionResult> testStoragePermissions(BuildContext context) async {
    try {
      // First, ensure we are authenticated
      await SupabaseService.refreshAuthState();
      final user = SupabaseService.client.auth.currentUser;
      
      if (user == null) {
        return StoragePermissionResult(
          success: false,
          message: 'Not authenticated. Please sign in first.',
          errorCode: 'not_authenticated',
        );
      }
      
      // Step 1: Check if bucket exists
      try {
        final buckets = await SupabaseService.client.storage.listBuckets();
        final bucketExists = buckets.any((b) => b.name == _testBucketName);
        
        if (!bucketExists) {
          return StoragePermissionResult(
            success: false,
            message: 'Bucket does not exist: $_testBucketName',
            errorCode: 'bucket_not_found',
          );
        }
      } catch (e) {
        return StoragePermissionResult(
          success: false,
          message: 'Error listing buckets: $e',
          errorCode: 'bucket_list_error',
        );
      }
      
      // Step 2: Try to list files in user's folder
      try {
        await SupabaseService.client.storage
            .from(_testBucketName)
            .list(path: user.id);
            
        print('Successfully listed files in user folder');
      } catch (e) {
        print('Error listing files: $e');
        // This might fail if folder doesn't exist yet, which is okay
      }
      
      // Step 3: Try to upload a test file
      try {
        final testData = Uint8List.fromList([1, 2, 3, 4]); // Tiny test file
        final testPath = '${user.id}/test_${DateTime.now().millisecondsSinceEpoch}.bin';
        
        print('Attempting to upload test file to: $testPath');
        await SupabaseService.client.storage
            .from(_testBucketName)
            .uploadBinary(
              testPath, 
              testData,
              fileOptions: const FileOptions(
                contentType: 'application/octet-stream',
              )
            );
            
        print('Test upload successful');
        
        // Try to delete the test file
        try {
          await SupabaseService.client.storage
              .from(_testBucketName)
              .remove([testPath]);
          print('Test file deleted');
        } catch (e) {
          print('Could not delete test file: $e');
        }
        
        return StoragePermissionResult(
          success: true,
          message: 'Storage permissions verified successfully',
          errorCode: null,
        );
      } catch (e) {
        print('Test upload failed: $e');
        String errorCode = 'upload_failed';
        
        if (e is StorageException) {
          errorCode = e.statusCode?.toString() ?? 'unknown';
        }
        
        if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
          errorCode = '403_forbidden';
        } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          errorCode = '401_unauthorized';
        }
        
        return StoragePermissionResult(
          success: false,
          message: 'Failed to upload test file: $e',
          errorCode: errorCode,
          fullError: e.toString(),
        );
      }
    } catch (e) {
      return StoragePermissionResult(
        success: false,
        message: 'Unexpected error during permission check: $e',
        errorCode: 'unexpected_error',
        fullError: e.toString(),
      );
    }
  }
  
  // Display results in UI
  static Future<void> checkAndShowResults(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing storage permissions...'),
          ],
        ),
      ),
    );
    
    // Run the test
    final result = await testStoragePermissions(context);
    
    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    // Show results
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(result.success ? 'Success' : 'Permission Error'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.message),
                if (result.errorCode != null) ...[
                  const SizedBox(height: 8),
                  Text('Error code: ${result.errorCode}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
                if (result.fullError != null) ...[
                  const SizedBox(height: 8),
                  const Text('Full error details:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[200],
                    width: double.infinity,
                    child: Text(
                      result.fullError!,
                      style: const TextStyle(fontFamily: 'Courier'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (!result.success)
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Sign out and try again
                  await SupabaseService.signOut(context);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please sign in again and retry')),
                    );
                  }
                },
                child: const Text('Sign Out'),
              ),
          ],
        ),
      );
    }
  }
}

class StoragePermissionResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? fullError;
  
  StoragePermissionResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.fullError,
  });
}
