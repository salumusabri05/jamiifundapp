import 'package:jamiifund/models/user_profile.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  // Supabase client
  static SupabaseClient get _supabase => SupabaseService.client;
  // Expose the Supabase client for use in other places
  static SupabaseClient get supabase => SupabaseService.client;
  static const String _profilesTable = 'profiles';
  
  // For convenience, re-expose the User type from Supabase
  // No need to create a mock User class

  // Get the current authenticated user
  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }
  
  // Get user profile by ID
  static Future<UserProfile?> getUserProfileById(String userId) async {
    try {
      final response = await _supabase
          .from(_profilesTable)
          .select()
          .eq('id', userId)
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
  
  // Get all users
  static Future<List<UserProfile>> getAllUsers() async {
    try {
      final response = await _supabase
          .from(_profilesTable)
          .select()
          .order('full_name', ascending: true);
      
      return (response as List).map((item) => UserProfile.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }
  
  // Follow a user
  static Future<void> followUser(String followerId, String followedId) async {
    try {
      await _supabase
          .from('user_follows')
          .insert({
            'follower_id': followerId,
            'followed_id': followedId,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }
  
  // Unfollow a user
  static Future<void> unfollowUser(String followerId, String followedId) async {
    try {
      await _supabase
          .from('user_follows')
          .delete()
          .match({
            'follower_id': followerId,
            'followed_id': followedId,
          });
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }
  
  // Get users followed by the current user
  static Future<List<UserProfile>> getFollowedUsers(String userId) async {
    try {
      final response = await _supabase
          .from('user_follows')
          .select('followed_id')
          .eq('follower_id', userId);
      
      final followedIds = (response as List).map((item) => item['followed_id'].toString()).toList();
      
      if (followedIds.isEmpty) {
        return [];
      }
      
      final userResponse = await _supabase
          .from(_profilesTable)
          .select()
          .inFilter('id', followedIds);
      
      return (userResponse as List).map((item) => UserProfile.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get followed users: $e');
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email, 
    required String password
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email, 
    required String password,
    required String fullName,
    String? username,
    String? phone,
  }) async {
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': username,
          'phone': phone,
        },
      );
      
      // If sign up successful, create a profile for the user
      if (authResponse.user != null) {
        await _supabase
            .from(_profilesTable)
            .insert({
              'id': authResponse.user!.id,
              'email': email,
              'full_name': fullName,
              'username': username,
              'phone': phone,
              'avatar_url': null,
              'bio': null,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
      }
      
      return authResponse;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
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
        
        // Update the profile in Supabase
        final response = await _supabase
            .from(_profilesTable)
            .update(dataToUpdate)
            .eq('id', userId)
            .select()
            .single();
        
        return UserProfile.fromJson(response);
      }
      
      // If no updates, fetch the current profile
      return await getUserProfileById(userId);
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }
  
  // Check if user is verified
  static Future<bool> isUserVerified(String userId) async {
    try {
      final response = await _supabase
          .from(_profilesTable)
          .select('is_verified')
          .eq('id', userId)
          .single();
      
      return response['is_verified'] == true;
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
      
      final response = await _supabase
          .from(_profilesTable)
          .select('is_admin')
          .eq('id', user.id)
          .single();
      
      return response['is_admin'] == true;
    } catch (e) {
      print('Error checking if user is admin: $e');
      return false;
    }
  }
  
  // Get list of users that the current user is mutually following with
  // (Users who follow the current user AND the current user follows them)
  static Future<List<UserProfile>> getMutualFollowers(String userId) async {
    try {
      // Get users who follow the current user
      final followersResponse = await _supabase
          .from('user_follows')
          .select('follower_id')
          .eq('followed_id', userId);
      
      final followerIds = (followersResponse as List).map((item) => item['follower_id'].toString()).toList();
      
      if (followerIds.isEmpty) {
        return [];
      }
      
      // Get users whom the current user follows
      final followingResponse = await _supabase
          .from('user_follows')
          .select('followed_id')
          .eq('follower_id', userId);
      
      final followingIds = (followingResponse as List).map((item) => item['followed_id'].toString()).toList();
      
      if (followingIds.isEmpty) {
        return [];
      }
      
      // Find the intersection (mutual followers)
      final mutualIds = followerIds.where((id) => followingIds.contains(id)).toList();
      
      if (mutualIds.isEmpty) {
        return [];
      }
      
      // Get user profiles for mutual followers
      final userResponse = await _supabase
          .from(_profilesTable)
          .select()
          .inFilter('id', mutualIds);
      
      return (userResponse as List).map((item) => UserProfile.fromJson(item)).toList();
    } catch (e) {
      print('Error getting mutual followers: $e');
      throw Exception('Failed to get mutual followers: $e');
    }
  }
  
  // Check if users are mutually following each other
  static Future<bool> areMutualFollowers(String userId1, String userId2) async {
    try {
      // Check if user1 follows user2
      final follows1to2Response = await _supabase
          .from('user_follows')
          .select()
          .eq('follower_id', userId1)
          .eq('followed_id', userId2);
      
      // Check if user2 follows user1
      final follows2to1Response = await _supabase
          .from('user_follows')
          .select()
          .eq('follower_id', userId2)
          .eq('followed_id', userId1);
      
      return (follows1to2Response as List).isNotEmpty && 
             (follows2to1Response as List).isNotEmpty;
    } catch (e) {
      print('Error checking mutual follow status: $e');
      return false;
    }
  }
  
  // Get mutual followers count for a user
  static Future<int> getMutualFollowersCount(String userId1, String userId2) async {
    try {
      // Get followers of user1
      final user1FollowersResponse = await _supabase
          .from('user_follows')
          .select('follower_id')
          .eq('followed_id', userId1);
      
      final user1FollowerIds = (user1FollowersResponse as List)
          .map((item) => item['follower_id'].toString())
          .toSet();
      
      // Get followers of user2
      final user2FollowersResponse = await _supabase
          .from('user_follows')
          .select('follower_id')
          .eq('followed_id', userId2);
      
      final user2FollowerIds = (user2FollowersResponse as List)
          .map((item) => item['follower_id'].toString())
          .toSet();
      
      // Find intersection of the two sets
      final mutualFollowerIds = user1FollowerIds.intersection(user2FollowerIds);
      
      return mutualFollowerIds.length;
    } catch (e) {
      print('Error getting mutual followers count: $e');
      return 0;
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
