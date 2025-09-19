import 'dart:io';
import 'package:jamiifund/models/verification_request.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:jamiifund/services/profile_verification_sync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationService {
  static const String _tableName = 'verification_requests';
  static const String _profilesTable = 'profiles';
  static const String _paymentMethodsTable = 'payment_methods';
  
  // Get Supabase client
  static SupabaseClient get _client => SupabaseService.client;

  // Create a new verification request with comprehensive user details
  static Future<VerificationRequest> createVerificationRequest(
    VerificationRequest request, {
    Map<String, dynamic>? profileDetails,
  }) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert(request.toMap())
          .select()
          .single();
      
      // If profile details are provided, update the profiles table
      if (profileDetails != null && profileDetails.isNotEmpty && request.userId != null) {
        await _client.from(_profilesTable).update({
          ...profileDetails,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', request.userId!);
      }
      
      // Sync with profile using the new service
      final createdRequest = VerificationRequest.fromMap(response);
      await ProfileVerificationSync.syncVerificationRequestToProfile(createdRequest);
      
      return createdRequest;
    } catch (e) {
      rethrow;
    }
  }
  
  // Submit comprehensive verification details
  static Future<VerificationRequest> submitVerificationDetails({
    required String userId,
    String? fullName,
    String? username,
    String? avatarUrl,
    String? website,
    String? phone,
    String? address,
    String? city,
    String? region,
    String? postalCode,
    bool? isOrganization,
    String? organizationName,
    String? organizationRegNumber,
    String? organizationType,
    String? organizationDescription,
    String? bio,
    String? email,
    String? location,
    String? idUrl,
    String? lipaNamba,
    String? bankAccountNumber,
    String? documentType,
    String? additionalNotes,
  }) async {
    try {
      // Create the verification request object
      final request = VerificationRequest(
        userId: userId,
        documentType: documentType ?? 'ID',
        idUrl: idUrl,
        status: 'pending',
        notes: additionalNotes,
        fullName: fullName,
        phoneNumber: phone,
        address: address,
      );
      
      // Create a map of profile details to update
      final profileDetails = <String, dynamic>{};
      if (fullName != null) profileDetails['full_name'] = fullName;
      if (username != null) profileDetails['username'] = username;
      if (avatarUrl != null) profileDetails['avatar_url'] = avatarUrl;
      if (website != null) profileDetails['website'] = website;
      if (phone != null) profileDetails['phone'] = phone;
      if (address != null) profileDetails['address'] = address;
      if (city != null) profileDetails['city'] = city;
      if (region != null) profileDetails['region'] = region;
      if (postalCode != null) profileDetails['postal_code'] = postalCode;
      if (isOrganization != null) profileDetails['is_organization'] = isOrganization;
      if (organizationName != null) profileDetails['organization_name'] = organizationName;
      if (organizationRegNumber != null) profileDetails['organization_reg_number'] = organizationRegNumber;
      if (organizationType != null) profileDetails['organization_type'] = organizationType;
      if (organizationDescription != null) profileDetails['organization_description'] = organizationDescription;
      if (bio != null) profileDetails['bio'] = bio;
      if (email != null) profileDetails['email'] = email;
      if (location != null) profileDetails['location'] = location;
      if (idUrl != null) profileDetails['id_url'] = idUrl;
      if (lipaNamba != null) profileDetails['lipa_namba'] = lipaNamba;
      if (bankAccountNumber != null) profileDetails['bank_account_number'] = bankAccountNumber;
      
      // Submit the verification request and update profile
      return await createVerificationRequest(request, profileDetails: profileDetails);
    } catch (e) {
      rethrow;
    }
  }

  // Get verification request by user ID
  static Future<VerificationRequest?> getVerificationRequestByUserId(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return VerificationRequest.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is verified
  static Future<bool> isUserVerified(String userId) async {
    try {
      // Primary check: Check the profiles table for is_verified column
      final profileResponse = await _client
          .from(_profilesTable)
          .select('is_verified')
          .eq('id', userId)
          .maybeSingle();
          
      // If is_verified is true in the profiles table, user is verified
      if (profileResponse != null && profileResponse['is_verified'] == true) {
        return true;
      }
      
      // Legacy fallback: check verification requests
      final request = await getVerificationRequestByUserId(userId);
      if (request != null && request.status == 'approved') {
        // Sync this to profiles table for future checks
        await _client
            .from(_profilesTable)
            .update({'is_verified': true})
            .eq('id', userId);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error checking verification status: $e');
      return false;
    }
  }

  // Upload ID document
  static Future<String> uploadIdDocument(String filePath, String userId) async {
    try {
      final fileExt = filePath.split('.').last;
      final fileName = 'id_document_$userId.$fileExt';
      
      // Create a Dart File object from the file path
      final file = File(filePath);
      
      await _client
          .storage
          .from('verification_documents')
          .upload(fileName, file);
      
      // Get the public URL of the uploaded file
      final fileUrl = _client
          .storage
          .from('verification_documents')
          .getPublicUrl(fileName);
          
      return fileUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Add payment method
  static Future<void> addPaymentMethod(String userId, String type, String accountNumber, String accountName) async {
    try {
      await _client.from(_paymentMethodsTable).insert({
        'user_id': userId,
        'type': type,
        'account_number': accountNumber,
        'account_name': accountName,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get payment methods by user ID
  static Future<List<Map<String, dynamic>>> getPaymentMethodsByUserId(String userId) async {
    try {
      final response = await _client
          .from(_paymentMethodsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
  
  // Admin Methods
  
  // Get all pending verification requests
  static Future<List<VerificationRequest>> getPendingVerificationRequests() async {
    try {
      // This would normally check if the current user is an admin
      // For now, we'll just return the data
      final response = await _client
          .from(_tableName)
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response)
          .map((map) => VerificationRequest.fromMap(map))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update verification request status (approve/reject)
  static Future<void> updateVerificationRequestStatus(
    String requestId,
    String status, {
    String? rejectionReason,
    Map<String, dynamic>? verificationDetails,
  }) async {
    try {
      // Update the verification request status
      final response = await _client.from(_tableName).update({
        'status': status,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', requestId).select().single();
      
      // If approved, update the profiles table
      if (status == 'approved') {
        final userId = response['user_id'] as String;
        
        // If verification details are provided, update the profiles table
        if (verificationDetails != null && verificationDetails.isNotEmpty) {
          await updateUserProfileVerificationDetails(userId, verificationDetails);
        } else {
          // Just mark the user as verified in the profiles table
          await _client.from(_profilesTable).update({
            'is_verified': true,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', userId);
        }
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user profile with verification details
  static Future<void> updateUserProfileVerificationDetails(
    String userId,
    Map<String, dynamic> verificationDetails,
  ) async {
    try {
      // Include the verified status and updated timestamp
      final dataToUpdate = {
        ...verificationDetails,
        'is_verified': true,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Update the profiles table with all the verification details
      await _client.from(_profilesTable).update(dataToUpdate).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all verification requests
  static Future<List<VerificationRequest>> getAllVerificationRequests() async {
    try {
      // This would normally check if the current user is an admin
      final response = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response)
          .map((map) => VerificationRequest.fromMap(map))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
