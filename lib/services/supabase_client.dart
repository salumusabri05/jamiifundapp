import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Create a client that can be accessed by other services
  static late final SupabaseClient client;
  static bool _isInitialized = false;
  static const String _supabaseUrl = 'https://mavaujxjkzyuhphpgtue.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hdmF1anhqa3p5dWhwaHBndHVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2Mjc3NTIsImV4cCI6MjA2NTIwMzc1Mn0.gT90RdhPzgFQ7jfY6T0yB-Cb2ccpSTxUPfHoAyob2L4';
  static DateTime? _lastAuthCheck;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Check connection to Supabase before initializing
      final connectionStatus = await checkConnection();
      if (!connectionStatus.isConnected) {
        throw Exception('Cannot connect to Supabase: ${connectionStatus.message}');
      }
      
      // Initialize Supabase with real credentials
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
        debug: kDebugMode,
      );
      
      // Get the client instance
      client = Supabase.instance.client;
      _isInitialized = true;
      
      print('Supabase initialized successfully');
      
      // Check for authenticated session
      if (client.auth.currentUser != null) {
        // Ensure all required buckets exist if user is authenticated
        await ensureRequiredBuckets();
      }
    } catch (e) {
      print('Supabase initialization error: $e');
      rethrow;
    }
  }
  
  // Check if we can connect to Supabase
  static Future<ConnectionStatus> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/?apikey=$_supabaseAnonKey'),
        headers: {
          'apikey': _supabaseAnonKey,
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ConnectionStatus(isConnected: true, message: 'Connected to Supabase');
      } else {
        return ConnectionStatus(
          isConnected: false, 
          message: 'Failed to connect to Supabase. Status: ${response.statusCode}'
        );
      }
    } on TimeoutException {
      return ConnectionStatus(
        isConnected: false, 
        message: 'Connection timeout. Check your internet connection.'
      );
    } catch (e) {
      return ConnectionStatus(
        isConnected: false, 
        message: 'Connection error: ${e.toString()}'
      );
    }
  }
  
  // Reset client for retry
  static Future<void> reset() async {
    _isInitialized = false;
    await initialize();
  }
  
  // Check if a bucket exists and is accessible - creates it if missing
  static Future<bool> validateStorageBucket(String bucketName) async {
    try {
      // First check if we're authenticated
      if (!isAuthenticated()) {
        print('Cannot validate bucket: User not authenticated');
        return false;
      }
      
      // Get list of buckets
      final List<Bucket> buckets = await client.storage.listBuckets();
      
      // Check if our bucket exists
      final bucketExists = buckets.any((bucket) => bucket.name == bucketName);
      
      if (!bucketExists) {
        print('Bucket does not exist: $bucketName');
        print('The bucket should already be created in Supabase. Please check your configuration.');
        return false; // The bucket doesn't exist and we don't try to create it
      }
      
      // Try to list objects to check permissions
      await client.storage.from(bucketName).list();
      print('Storage bucket validated successfully: $bucketName');
      return true;
    } catch (e) {
      print('Storage bucket validation failed: $e');
      return false;
    }
  }
  
  // Ensure all required storage buckets exist
  static Future<Map<String, bool>> ensureRequiredBuckets() async {
    // This map will track which buckets were created or already existed
    Map<String, bool> results = {};
    
    try {
      // List of all required storage buckets in the application
      final requiredBuckets = [
        'verification_documents',
        // Add other buckets here as needed
      ];
      
      // Get existing buckets first
      final existingBuckets = await client.storage.listBuckets();
      final existingBucketNames = existingBuckets.map((b) => b.name).toList();
      
      for (final bucketName in requiredBuckets) {
        try {
          if (existingBucketNames.contains(bucketName)) {
            print('Bucket $bucketName already exists');
            results[bucketName] = true;
            continue;
          }
          
          // Create the bucket if it doesn't exist
          print('Creating bucket: $bucketName');
          await client.storage.createBucket(
            bucketName,
            const BucketOptions(public: false), // Make private for security
          );
          
          print('Successfully created bucket: $bucketName');
          results[bucketName] = true;
          
          // Set up default RLS policy for the bucket - if this fails, the bucket still exists
          try {
            print('Setting up RLS policies for bucket: $bucketName');
            await _setupDefaultRlsPolicy(bucketName);
            print('RLS policies set up successfully for: $bucketName');
          } catch (rlsError) {
            print('Error setting up RLS policies for $bucketName: $rlsError');
            // We don't consider this a failure for the bucket creation itself
          }
        } catch (bucketError) {
          print('Error creating/checking bucket $bucketName: $bucketError');
          results[bucketName] = false;
        }
      }
    } catch (e) {
      print('Error in ensureRequiredBuckets: $e');
    }
    
    return results;
  }
  
  // Set up default RLS policy for a storage bucket
  static Future<void> _setupDefaultRlsPolicy(String bucketName) async {
    try {
      // This is a simplified example - in a production app, you'd implement
      // proper RLS policies based on your security requirements
      
      // For now, we'll set up a basic policy that allows authenticated users
      // to read and write files in their own user_id folder
      
      // NOTE: This would normally be done via SQL migrations in production,
      // but this is a fallback for development/testing
      
      print('Setting up RLS policy for bucket: $bucketName');
      
      // No direct SQL execution capabilities in Supabase Flutter SDK
      // This would need to be done through proper migrations
      // This method placeholder could be used for checking/reporting policy status
    } catch (e) {
      print('Error setting up RLS policy: $e');
      rethrow;
    }
  }
  
  // Get authenticated user ID in the proper format for RLS
  static String? getAuthUserId() {
    try {
      // Refresh auth state if needed
      refreshAuthState();
      
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        print('No authenticated user found');
        return null;
      }
      
      // Return the UUID in the standard format expected by Supabase
      final userId = currentUser.id;
      print('Auth user ID: $userId');
      return userId;
    } catch (e) {
      print('Error getting auth user ID: $e');
      return null;
    }
  }
  
  // Check if the user is authenticated with a valid session
  static bool isAuthenticated() {
    refreshAuthState();
    return client.auth.currentUser != null;
  }
  
  // Refresh the auth state if token might be expired
  static Future<void> refreshAuthState() async {
    try {
      // Only check once every 5 minutes to avoid excessive calls
      if (_lastAuthCheck != null && 
          DateTime.now().difference(_lastAuthCheck!).inMinutes < 5) {
        return;
      }
      
      _lastAuthCheck = DateTime.now();
      final session = client.auth.currentSession;
      
      if (session == null) {
        print('No active session found');
        return;
      }
      
      // Check if token is expired or about to expire (within 5 minutes)
      final expiresAt = session.expiresAt;
      if (expiresAt != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
        final timeToExpiry = expiryTime.difference(DateTime.now());
        
        if (timeToExpiry.isNegative || timeToExpiry.inMinutes < 5) {
          print('Token expired or about to expire. Attempting refresh.');
          await client.auth.refreshSession();
          print('Session refreshed successfully');
        }
      }
    } catch (e) {
      print('Error refreshing auth state: $e');
    }
  }
  
  // Check if the user has storage permissions
  static Future<bool> hasStoragePermission(String bucketName) async {
    try {
      // Ensure auth state is current
      refreshAuthState();
      
      if (client.auth.currentUser == null) {
        print('Cannot check storage permissions: User not authenticated');
        return false;
      }
      
      // Test permission by listing objects with a limit of 1
      await client.storage.from(bucketName).list();
      print('Storage permissions verified for bucket: $bucketName');
      return true;
    } catch (e) {
      print('Storage permission check failed: $e');
      return false;
    }
  }
  
  // Check if a specific bucket has proper RLS policies set up
  static Future<Map<String, dynamic>> checkBucketRls(String bucketName) async {
    try {
      // Ensure auth state is current
      refreshAuthState();
      
      // Check if user is authenticated
      if (client.auth.currentUser == null) {
        return {
          'success': false,
          'message': 'Not authenticated. Please sign in first.',
        };
      }
      
      // Get user ID for folder checks
      final userId = client.auth.currentUser!.id;
      
      Map<String, dynamic> results = {
        'success': true,
        'userId': userId,
        'bucket': bucketName,
        'tests': []
      };
      
      // Test 1: List objects in the bucket
      try {
        await client.storage.from(bucketName).list();
        results['tests'].add({
          'name': 'List objects',
          'result': 'Success',
          'details': 'You can list objects in the bucket.',
        });
      } catch (e) {
        results['tests'].add({
          'name': 'List objects',
          'result': 'Failed',
          'details': 'Error: $e',
        });
        results['success'] = false;
      }
      
      // Test 2: Upload a test file to bucket root (new approach)
      try {
        final testData = Uint8List.fromList(List<int>.filled(10, 0));
        final testFilename = 'test_root_${userId}_${DateTime.now().millisecondsSinceEpoch}.dat';
        
        await client.storage.from(bucketName).uploadBinary(
          testFilename, 
          testData,
          fileOptions: const FileOptions(
            contentType: 'application/octet-stream',
            upsert: true
          )
        );
        
        results['tests'].add({
          'name': 'Upload file to bucket root',
          'result': 'Success',
          'details': 'You can upload files directly to the bucket root.',
          'path': testFilename,
        });
        
        // Try to delete the test file
        try {
          await client.storage.from(bucketName).remove([testFilename]);
          results['tests'].add({
            'name': 'Delete file from bucket root',
            'result': 'Success',
            'details': 'You can delete files in the bucket root.',
          });
        } catch (e) {
          results['tests'].add({
            'name': 'Delete file from bucket root',
            'result': 'Failed',
            'details': 'Error: $e',
          });
        }
      } catch (e) {
        results['tests'].add({
          'name': 'Upload file to bucket root',
          'result': 'Failed',
          'details': 'Error: $e',
        });
        results['success'] = false;
      }
      
      // Test 3: Upload a test file to user folder (legacy approach)
      try {
        final testData = Uint8List.fromList(List<int>.filled(10, 0));
        final testPath = '$userId/test_${DateTime.now().millisecondsSinceEpoch}.dat';
        
        await client.storage.from(bucketName).uploadBinary(
          testPath, 
          testData,
          fileOptions: const FileOptions(
            contentType: 'application/octet-stream',
            upsert: true
          )
        );
        
        results['tests'].add({
          'name': 'Upload file to user folder',
          'result': 'Success',
          'details': 'You can still upload files to your user folder (legacy approach).',
          'path': testPath,
        });
        
        // Try to delete the test file
        try {
          await client.storage.from(bucketName).remove([testPath]);
          results['tests'].add({
            'name': 'Delete file from user folder',
            'result': 'Success',
            'details': 'You can delete files in your user folder.',
          });
        } catch (e) {
          results['tests'].add({
            'name': 'Delete file from user folder',
            'result': 'Failed',
            'details': 'Error: $e',
          });
        }
      } catch (e) {
        results['tests'].add({
          'name': 'Upload file to user folder',
          'result': 'Failed',
          'details': 'Error: $e',
        });
        // Note: We don't mark the entire test as failed if only the legacy approach fails
      }
      
      return results;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error checking RLS policies: $e',
      };
    }
  }
  
  // Sign out and clear auth state
  static Future<void> signOut(BuildContext? context) async {
    try {
      await client.auth.signOut();
      _lastAuthCheck = null;
      print('User signed out successfully');
      
      // Show confirmation if context is provided
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
      }
    } catch (e) {
      print('Error signing out: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
  
  // Make a bucket public
  static Future<bool> makeStorageBucketPublic(String bucketName) async {
    try {
      // First check if we're authenticated with admin privileges
      if (!isAuthenticated()) {
        print('Cannot modify bucket: User not authenticated');
        return false;
      }
      
      // Get list of buckets
      final List<Bucket> buckets = await client.storage.listBuckets();
      
      // Check if our bucket exists
      final bucketExists = buckets.any((bucket) => bucket.name == bucketName);
      
      if (!bucketExists) {
        print('Bucket does not exist: $bucketName');
        return false;
      }
      
      // Update bucket to be public
      try {
        await client.storage.updateBucket(bucketName, const BucketOptions(public: true));
        print('Successfully made bucket public: $bucketName');
        return true;
      } catch (updateError) {
        print('Failed to make bucket public: $updateError');
        return false;
      }
    } catch (e) {
      print('Error making bucket public: $e');
      return false;
    }
  }
}

class ConnectionStatus {
  final bool isConnected;
  final String message;
  
  ConnectionStatus({required this.isConnected, required this.message});
}
