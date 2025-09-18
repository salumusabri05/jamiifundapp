import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:jamiifund/models/user_profile.dart';

class UserService {
  static SupabaseClient get _client => SupabaseService.client;
  static const String _profilesTable = 'profiles';

  // Get the current authenticated user
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return _client.auth.currentUser != null;
  }
  
  // Get user profile by ID
  static Future<UserProfile?> getUserProfileById(String userId) async {
    try {
      final data = await _client
          .from(_profilesTable)
          .select()
          .eq('id', userId)
          .single();
          
      return UserProfile.fromJson(data);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email, 
    required String password
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email, 
    required String password,
    required String fullName,
    String? username,
    String? phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'username': username,
        'phone': phone,
      },
    );
    
    // If signup successful, create a profile
    if (response.user != null) {
      await _client.from(_profilesTable).upsert({
        'id': response.user!.id,
        'full_name': fullName,
        'username': username,
        'email': email,
        'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
    
    return response;
  }

  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get current user profile
  static Future<UserProfile?> getCurrentUserProfile() async {
    final user = getCurrentUser();
    if (user == null) {
      return null;
    }
    
    return await getUserProfileById(user.id);
  }

  // Update user profile
  static Future<UserProfile?> updateUserProfile({
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
    bool? isVerified,
    String? idUrl,
  }) async {
    try {
      final dataToUpdate = <String, dynamic>{};
      
      if (fullName != null) dataToUpdate['full_name'] = fullName;
      if (username != null) dataToUpdate['username'] = username;
      if (avatarUrl != null) dataToUpdate['avatar_url'] = avatarUrl;
      if (website != null) dataToUpdate['website'] = website;
      if (phone != null) dataToUpdate['phone'] = phone;
      if (address != null) dataToUpdate['address'] = address;
      if (city != null) dataToUpdate['city'] = city;
      if (region != null) dataToUpdate['region'] = region;
      if (postalCode != null) dataToUpdate['postal_code'] = postalCode;
      if (isOrganization != null) dataToUpdate['is_organization'] = isOrganization;
      if (organizationName != null) dataToUpdate['organization_name'] = organizationName;
      if (organizationRegNumber != null) dataToUpdate['organization_reg_number'] = organizationRegNumber;
      if (organizationType != null) dataToUpdate['organization_type'] = organizationType;
      if (organizationDescription != null) dataToUpdate['organization_description'] = organizationDescription;
      if (bio != null) dataToUpdate['bio'] = bio;
      if (email != null) dataToUpdate['email'] = email;
      if (location != null) dataToUpdate['location'] = location;
      if (isVerified != null) dataToUpdate['is_verified'] = isVerified;
      if (idUrl != null) dataToUpdate['id_url'] = idUrl;
      
      // Only update if we have data to update
      if (dataToUpdate.isNotEmpty) {
        dataToUpdate['updated_at'] = DateTime.now().toIso8601String();
        
        await _client
            .from(_profilesTable)
            .update(dataToUpdate)
            .eq('id', userId);
            
        return await getUserProfileById(userId);
      }
      
      return await getUserProfileById(userId);
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }
  
  // Check if user is verified
  static Future<bool> isUserVerified(String userId) async {
    try {
      final data = await _client
          .from(_profilesTable)
          .select('is_verified')
          .eq('id', userId)
          .single();
          
      return data['is_verified'] == true;
    } catch (e) {
      print('Error checking if user is verified: $e');
      return false;
    }
  }
  
  // Check if current user is an admin
  static Future<bool> isUserAdmin() async {
    try {
      final user = getCurrentUser();
      if (user == null) return false;
      
      final data = await _client
          .from(_profilesTable)
          .select('is_admin')
          .eq('id', user.id)
          .single();
          
      return data['is_admin'] == true;
    } catch (e) {
      print('Error checking if user is admin: $e');
      return false;
    }
  }
  
  // Convert a verification request to user profile updates
  static Map<String, dynamic> verificationRequestToProfileUpdates(Map<String, dynamic> requestData) {
    final updates = <String, dynamic>{};
    
    // Map verification request fields to profile fields
    if (requestData['full_name'] != null) updates['full_name'] = requestData['full_name'];
    if (requestData['avatar_url'] != null) updates['avatar_url'] = requestData['avatar_url'];
    if (requestData['website'] != null) updates['website'] = requestData['website'];
    if (requestData['phone'] != null) updates['phone'] = requestData['phone'];
    if (requestData['address'] != null) updates['address'] = requestData['address'];
    if (requestData['city'] != null) updates['city'] = requestData['city'];
    if (requestData['region'] != null) updates['region'] = requestData['region'];
    if (requestData['postal_code'] != null) updates['postal_code'] = requestData['postal_code'];
    if (requestData['is_organization'] != null) updates['is_organization'] = requestData['is_organization'];
    if (requestData['organization_name'] != null) updates['organization_name'] = requestData['organization_name'];
    if (requestData['organization_reg_number'] != null) updates['organization_reg_number'] = requestData['organization_reg_number'];
    if (requestData['organization_type'] != null) updates['organization_type'] = requestData['organization_type'];
    if (requestData['organization_description'] != null) updates['organization_description'] = requestData['organization_description'];
    if (requestData['bio'] != null) updates['bio'] = requestData['bio'];
    if (requestData['location'] != null) updates['location'] = requestData['location'];
    if (requestData['id_url'] != null) updates['id_url'] = requestData['id_url'];
    
    return updates;
  }
}
