import 'dart:io';
import 'package:jamiifund/models/unified_verification.dart';
import 'package:jamiifund/models/verification_member.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:jamiifund/services/profile_verification_sync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class UnifiedVerificationService {
  static const String _tableName = 'verifications';
  static const String _membersTableName = 'verification_members';
  
  // Get Supabase client
  static SupabaseClient get _client => SupabaseService.client;
  
  // Create or update a verification request
  static Future<UnifiedVerification> saveVerification(UnifiedVerification verification) async {
    try {
      final userId = verification.userId ?? _client.auth.currentUser?.id;
      
      if (userId == null) {
        throw Exception('User must be logged in to submit verification');
      }
      
      // Check if this user already has a verification
      final existingVerification = await getVerificationByUserId(userId);
      
      Map<String, dynamic> verificationData = verification.toMap();
      verificationData['user_id'] = userId;
      
      // Remove members from main verification data since they will be saved separately
      final members = List<VerificationMember>.from(verification.members);
      verificationData.remove('members');
      
      UnifiedVerification savedVerification;
      
      try {
        // If there's an existing verification, update it; otherwise create new
        if (existingVerification != null) {
          final response = await _client
              .from(_tableName)
              .update(verificationData)
              .eq('user_id', userId)
              .select()
              .maybeSingle();
              
          if (response == null) {
            throw Exception('Failed to update verification record');
          }
          savedVerification = UnifiedVerification.fromMap(response);
        } else {
          final response = await _client
              .from(_tableName)
              .insert(verificationData)
              .select()
              .maybeSingle();
              
          if (response == null) {
            throw Exception('Failed to create verification record');
          }
          savedVerification = UnifiedVerification.fromMap(response);
        }
      } catch (e) {
        print('Error saving verification: $e');
        if (e.toString().contains('does not exist')) {
          throw Exception('The verifications table does not exist. Please run migrations first.');
        }
        rethrow;
      }
      
      // Sync verification data to profile
      await ProfileVerificationSync.syncVerificationToProfile(savedVerification);
      
          // If there are members, handle them separately
      if (members.isNotEmpty) {
        // If we're updating, delete existing members first
        if (existingVerification != null) {
          await _client
              .from(_membersTableName)
              .delete()
              .eq('verification_id', savedVerification.id!); // Non-null assertion
        }
        
        // Then insert all members
        for (var member in members) {
          final memberData = member.toMap();
          memberData['verification_id'] = savedVerification.id!; // Non-null assertion
          
          await _client
              .from(_membersTableName)
              .insert(memberData);
        }
      }
      
      // Fetch the complete verification with members
      final completeVerification = await getVerificationById(savedVerification.id!);
      // Return non-nullable verification, or throw an exception if null
      if (completeVerification == null) {
        throw Exception('Failed to retrieve verification after saving');
      }
      return completeVerification;    } catch (e) {
      print('Error saving verification: $e');
      rethrow;
    }
  }
  
  // Get verification by ID with members
  static Future<UnifiedVerification?> getVerificationById(String id) async {
    try {
      // Get the main verification data
      final verificationData = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle()
          .single();
      
      // Get the members data
      final membersData = await _client
          .from(_membersTableName)
          .select()
          .eq('verification_id', id);
          
      // Parse members
      List<VerificationMember> members = [];
      // membersData is always a List in Supabase response
      members = (membersData as List)
        .map((item) => VerificationMember.fromMap(item))
        .toList();
      
      // Create the verification object with members
      final verification = UnifiedVerification.fromMap(verificationData);
      return verification.copyWith(members: members);
      
    } catch (e) {
      print('Error getting verification: $e');
      return null;
    }
  }
  
  // Get verification by user ID with members
  static Future<UnifiedVerification?> getVerificationByUserId(String userId) async {
    try {
      // Get the verification ID - use maybeSingle to handle no records case
      final verificationData = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      // If no verification exists, return null
      if (verificationData == null) {
        return null;
      }
      
      // Get the verification with members
      return await getVerificationById(verificationData['id']);
      
    } catch (e) {
      print('Error getting verification by user ID: $e');
      
      // Check if the error is because the table doesn't exist
      if (e.toString().contains('does not exist')) {
        print('The verifications table does not exist yet. Please run migrations.');
        return null;
      }
      
      return null;
    }
  }
  
  // Upload file to Storage
  static Future<String?> uploadFile(File file, String userId, String folderName) async {
    try {
      final fileExt = path.extension(file.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = '$folderName/$userId/$fileName';
      
      // Upload file to storage
      await _client
          .storage
          .from('verification_documents')
          .upload(filePath, file);
          
      // Get public URL for the file
      final fileUrl = _client
          .storage
          .from('verification_documents')
          .getPublicUrl(filePath);
          
      return fileUrl;
      
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }
  
  // Check verification status
  static Future<String> checkVerificationStatus(String userId) async {
    try {
      final verification = await getVerificationByUserId(userId);
      return verification?.status ?? 'not_submitted';
    } catch (e) {
      print('Error checking verification status: $e');
      return 'error';
    }
  }
}
