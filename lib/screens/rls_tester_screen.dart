import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:jamiifund/utils/storage_bucket_setup_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RlsTester extends StatefulWidget {
  const RlsTester({super.key});

  @override
  State<RlsTester> createState() => _RlsTesterState();
}

class _RlsTesterState extends State<RlsTester> {
  String _result = 'No test run yet';
  bool _isLoading = false;
  final _bucketName = 'verification_documents';
  
  Future<void> _testDirectUpload() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing direct upload to public bucket...';
    });
    
    try {
      // Ensure we have the latest auth state
      await SupabaseService.refreshAuthState();
      
      // Check if user is authenticated
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _result = 'ERROR: Not authenticated. Please sign in first.';
          _isLoading = false;
        });
        return;
      }
      
      try {
        // Generate test data and filename
        final testData = List<int>.filled(10, 0);
        final userId = user.id;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final testFileName = 'id_${userId}_${timestamp}.dat';
        
        // Upload directly to bucket root
        await SupabaseService.client.storage
            .from(_bucketName)
            .uploadBinary(
              testFileName, 
              Uint8List.fromList(testData),
              fileOptions: const FileOptions(
                contentType: 'application/octet-stream',
                upsert: true
              )
            );
        
        // Get the public URL for verification
        final fileUrl = SupabaseService.client.storage
            .from(_bucketName)
            .getPublicUrl(testFileName);
            
        // Update result with success
        setState(() {
          _result = 'SUCCESS: Direct upload to public bucket PASSED!\n\n'
                   'Successfully uploaded file directly to the bucket root.\n'
                   'Filename: $testFileName\n\n'
                   'Public URL: $fileUrl\n\n'
                   'The public bucket is working correctly with the simplified upload structure.';
          _isLoading = false;
        });
        
        // Clean up by removing the test file
        await SupabaseService.client.storage
            .from(_bucketName)
            .remove([testFileName]);
            
      } catch (e) {
        // If direct upload fails, show error
        setState(() {
          _result = 'ERROR: Direct upload test FAILED: $e\n\n'
                   'Please verify your authentication and RLS policies for the bucket.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'General error: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _testRlsPermissions() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing RLS permissions...';
    });
    
    try {
      // Ensure we have the latest auth state
      await SupabaseService.refreshAuthState();
      
      // Check if user is authenticated
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _result = 'ERROR: Not authenticated. Please sign in first.';
          _isLoading = false;
        });
        return;
      }
      
      // Log user information
      String resultLog = 'User ID: ${user.id}\n';
      resultLog += 'Email: ${user.email}\n';
      resultLog += 'Created at: ${user.createdAt}\n\n';
      
      // Step 1: Check auth token info
      try {
        final session = SupabaseService.client.auth.currentSession;
        if (session != null) {
          final expiresAt = session.expiresAt;
          final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiresAt! * 1000);
          final timeToExpiry = expiryTime.difference(DateTime.now());
          
          resultLog += 'Auth Token Status:\n';
          resultLog += 'Expires in: ${timeToExpiry.inMinutes} minutes\n';
          resultLog += 'Token valid: ${!timeToExpiry.isNegative}\n\n';
        } else {
          resultLog += 'No active session found\n\n';
        }
      } catch (e) {
        resultLog += 'Error checking token: $e\n\n';
      }
      
      // Step 2: Check bucket access
      try {
        resultLog += 'Testing bucket list access...\n';
        final buckets = await SupabaseService.client.storage.listBuckets();
        final bucketNames = buckets.map((b) => b.name).join(', ');
        
        resultLog += 'Found buckets: $bucketNames\n';
        resultLog += 'Target bucket exists: ${buckets.any((b) => b.name == _bucketName)}\n\n';
      } catch (e) {
        resultLog += 'Error listing buckets: $e\n\n';
      }
      
      // Step 3: Use the new RLS check method which is more comprehensive
      resultLog += 'Running complete RLS policy tests...\n';
      final rlsResults = await SupabaseService.checkBucketRls(_bucketName);
      
      if (rlsResults['success'] == true) {
        resultLog += 'RLS policy tests completed successfully!\n\n';
      } else {
        resultLog += 'RLS policy tests found issues.\n\n';
      }
      
      // Format test results nicely
      final tests = rlsResults['tests'] as List<dynamic>;
      for (final test in tests) {
        final name = test['name'];
        final result = test['result'];
        final details = test['details'];
        
        resultLog += '$name: $result\n';
        resultLog += '  $details\n';
        if (test.containsKey('path')) {
          resultLog += '  Path: ${test['path']}\n';
        }
        resultLog += '\n';
      }
      
      // Final result
      setState(() {
        _result = resultLog;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'General error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RLS Permission Tester'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testRlsPermissions,
              child: Text(_isLoading ? 'Testing...' : 'Test RLS Permissions'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testDirectUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Test Direct Upload to Public Bucket'),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SelectableText(
                    _result,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                try {
                  await SupabaseService.signOut(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
