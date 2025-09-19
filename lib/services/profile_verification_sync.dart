import 'package:jamiifund/models/unified_verification.dart';
import 'package:jamiifund/models/verification_request.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:jamiifund/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileVerificationSync {
  static SupabaseClient get _client => SupabaseService.client;
  static const String _profilesTable = 'profiles';
  static const String _verificationsTable = 'verifications';

  /// Synchronizes data from a unified verification to the user's profile
  static Future<void> syncVerificationToProfile(UnifiedVerification verification) async {
    try {
      if (verification.userId == null) {
        throw Exception('User ID is required for profile sync');
      }
      
      // Create profile update data based on verification
      final Map<String, dynamic> profileData = {
        'full_name': verification.fullName,
        'phone': verification.phone,
        'address': verification.address,
        // We'll mark as verified only if status is "approved"
        'is_verified': verification.status == 'approved',
        'is_organization': verification.isOrganization,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Add organization-specific data if this is an organization
      if (verification.isOrganization) {
        profileData['organization_name'] = verification.organizationName;
        profileData['organization_reg_number'] = verification.organizationRegNumber;
        profileData['organization_description'] = 
            'Organization registered under verification process'; // Default description
        
        // Set a default organization type if not already set
        profileData['organization_type'] = 'Registered Organization';
      }
      
      // Set ID URL if available
      if (verification.idDocumentUrl != null) {
        profileData['id_url'] = verification.idDocumentUrl;
      }
      
      // Update the profile
      await _client
          .from(_profilesTable)
          .update(profileData)
          .eq('id', verification.userId!);
      
    } catch (e) {
      print('Error syncing verification to profile: $e');
      rethrow;
    }
  }

  /// Synchronizes data from a verification request to the user's profile
  static Future<void> syncVerificationRequestToProfile(VerificationRequest request) async {
    try {
      if (request.userId == null) {
        throw Exception('User ID is required for profile sync');
      }
      
      // Create profile update data based on verification request
      final Map<String, dynamic> profileData = {
        'full_name': request.fullName,
        'phone': request.phoneNumber,
        'address': request.address,
        // We'll mark as verified only if status is "approved"
        'is_verified': request.status == 'approved',
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Add ID URL if available
      if (request.idDocumentUrl != null) {
        profileData['id_url'] = request.idDocumentUrl;
      }
      
      // Update the profile
      await _client
          .from(_profilesTable)
          .update(profileData)
          .eq('id', request.userId!);
      
    } catch (e) {
      print('Error syncing verification request to profile: $e');
      rethrow;
    }
  }
  
  /// Synchronizes basic data from profile to a new verification
  static Future<Map<String, dynamic>> getProfileDataForVerification(String userId) async {
    try {
      final response = await _client
          .from(_profilesTable)
          .select()
          .eq('id', userId)
          .single();
      
      final profile = UserProfile.fromJson(response);
      
      return {
        'full_name': profile.fullName,
        'email': profile.email,
        'phone': profile.phone,
        'address': profile.address,
        'is_organization': profile.isOrganization ?? false,
        'organization_name': profile.organizationName,
        'organization_reg_number': profile.organizationRegNumber,
      };
    } catch (e) {
      print('Error getting profile data for verification: $e');
      return {}; // Return empty map if profile not found
    }
  }
}
