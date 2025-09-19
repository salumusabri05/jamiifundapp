import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamiifund/models/user_profile.dart';
import 'package:jamiifund/screens/user_detail_screen.dart';
import 'package:jamiifund/services/user_service.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  List<UserProfile> _users = [];
  List<UserProfile> _filteredUsers = [];
  bool _isLoading = false;
  String? _errorMessage;
  Set<String> _followedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'You must be logged in to view users';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load users from Supabase
      final users = await UserService.getAllUsers();
      
      // Load followed users
      final followed = await UserService.getFollowedUsers(currentUser.id);
      final followedIds = followed.map((user) => user.id).toSet();

      setState(() {
        _users = users.where((user) => user.id != currentUser.id).toList();
        _filteredUsers = List.from(_users);
        _followedUsers = Set<String>.from(followedIds);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers = _users
            .where((user) => 
                user.fullName.toLowerCase().contains(query.toLowerCase()) ||
                (user.bio?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  Future<void> _toggleFollow(String userId) async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) return;

    setState(() {
      if (_followedUsers.contains(userId)) {
        _followedUsers.remove(userId);
      } else {
        _followedUsers.add(userId);
      }
    });

    try {
      if (_followedUsers.contains(userId)) {
        await UserService.followUser(currentUser.id, userId);
      } else {
        await UserService.unfollowUser(currentUser.id, userId);
      }
    } catch (e) {
      // Revert the UI change on error
      setState(() {
        if (_followedUsers.contains(userId)) {
          _followedUsers.remove(userId);
        } else {
          _followedUsers.add(userId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update following: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Community',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8A2BE2)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0, duration: 300.ms),

          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8A2BE2)))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.red[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8A2BE2),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(
                                'Try Again',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_outline, size: 48, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  'No users found',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            color: const Color(0xFF8A2BE2),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                final isFollowing = _followedUsers.contains(user.id);
                                
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12.0),
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF8A2BE2),
                                      backgroundImage: user.avatarUrl != null
                                          ? NetworkImage(user.avatarUrl!)
                                          : null,
                                      radius: 28,
                                      child: user.avatarUrl == null
                                          ? Text(
                                              user.fullName[0].toUpperCase(),
                                              style: GoogleFonts.nunito(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                    title: Text(
                                      user.fullName,
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: user.bio != null
                                        ? Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              user.bio!,
                                              style: GoogleFonts.nunito(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : null,
                                    trailing: OutlinedButton(
                                      onPressed: () => _toggleFollow(user.id),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: isFollowing ? Colors.grey : const Color(0xFF8A2BE2),
                                        side: BorderSide(
                                          color: isFollowing ? Colors.grey : const Color(0xFF8A2BE2),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      child: Text(isFollowing ? 'Following' : 'Follow'),
                                    ),
                                    onTap: () {
                                      // Navigate to user detail screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserDetailScreen(user: user),
                                        ),
                                      );
                                    },
                                  ),
                                ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index));
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
