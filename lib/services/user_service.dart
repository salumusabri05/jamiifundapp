import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamiifund/services/supabase_client.dart';

class UserProfile {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? avatar;
  final DateTime? createdAt;
  final Map<String, dynamic> metadata;

  UserProfile({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.avatar,
    this.createdAt,
    this.metadata = const {},
  });

  factory UserProfile.fromSupabaseUser(User user, {Map<String, dynamic> profileData = const {}}) {
    DateTime? createdAt;
    try {
      // Try to get createdAt from profile data first
      if (profileData['created_at'] != null) {
        createdAt = DateTime.parse(profileData['created_at']);
      } else {
        // Fallback to current time if no date is available
        createdAt = DateTime.now();
      }
    } catch (e) {
      // Ignore parsing errors and leave createdAt as current time
      print('Error parsing date: $e');
      createdAt = DateTime.now();
    }
    
    return UserProfile(
      id: user.id,
      email: user.email,
      fullName: profileData['full_name'] ?? user.userMetadata?['full_name'],
      phone: profileData['phone'] ?? user.userMetadata?['phone'],
      avatar: profileData['avatar_url'] ?? user.userMetadata?['avatar_url'],
      createdAt: createdAt,
      metadata: user.userMetadata ?? {},
    );
  }

  factory UserProfile.empty() {
    return UserProfile(
      id: '',
      email: '',
      fullName: '',
      phone: '',
      avatar: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatar,
    };
  }
}

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

  // Sign in with email and password
  static Future<AuthResponse> signIn({required String email, required String password}) async {
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
    String? phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
      },
    );

    if (response.user != null) {
      // Create a profile record in the profiles table
      await _client.from(_profilesTable).insert({
        'id': response.user!.id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get user profile
  static Future<UserProfile> getUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Fetch additional profile data from profiles table
      final profileData = await _client
          .from(_profilesTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromSupabaseUser(user, profileData: profileData);
    } catch (e) {
      // If the profile doesn't exist or another error occurs, return basic user data
      final user = _client.auth.currentUser;
      if (user != null) {
        return UserProfile.fromSupabaseUser(user);
      }
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
  }) async {
    final user = _client.auth.currentUser;
    
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Update the user metadata
    await _client.auth.updateUser(
      UserAttributes(
        data: {
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      ),
    );

    // Update the profiles table
    await _client.from(_profilesTable).upsert({
      'id': user.id,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
