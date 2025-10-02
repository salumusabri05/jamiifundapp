import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamiifund/models/user_profile.dart';
import 'package:jamiifund/screens/user_detail_screen.dart';
import 'package:jamiifund/services/user_service.dart';
import 'package:jamiifund/utils/supabase_helper.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  List<UserProfile> _users = [];
  List<UserProfile> _filteredUsers = [];
  List<UserProfile> _followRequestUsers = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Maps for tracking follow status
  Map<String, String> _followStatus = {}; // userId -> status ('accepted', 'pending', null)
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    print('Starting _loadUsers method...');
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) {
      print('No current user found');
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
      // Load all users from profiles table with debug info
      print('Fetching all users from profiles table...');
      final users = await UserService.getAllUsers();
      print('Retrieved ${users.length} users from profiles table');
      
      // Load follow requests for current user
      print('Fetching pending follow requests...');
      final followRequests = await UserService.getPendingFollowRequests(currentUser.id);
      print('Retrieved ${followRequests.length} pending follow requests');
      
      // Create a map to track follow status for each user
      final followStatusMap = <String, String>{};
      
      // Check follow status for each user
      print('Checking follow status for each user...');
      for (var user in users) {
        if (user.id == currentUser.id) continue; // Skip current user
        
        final status = await UserService.getFollowRequestStatus(currentUser.id, user.id);
        print('Status for user ${user.fullName}: ${status ?? "null"}');
        if (status != null) {
          followStatusMap[user.id] = status;
        }
      }
      print('Follow status map contains ${followStatusMap.length} entries');

      final filteredUsers = users.where((user) => user.id != currentUser.id).toList();
      print('Filtered to ${filteredUsers.length} users (excluding current user)');
      
      if (mounted) {
        setState(() {
          _users = filteredUsers;
          _filteredUsers = List.from(filteredUsers);
          _followRequestUsers = followRequests;
          _followStatus = followStatusMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading users: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load users: ${e.toString()}';
          _isLoading = false;
        });
      }
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
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to follow users')),
      );
      return;
    }
    
    final currentStatus = _followStatus[userId];
    print('Current follow status for $userId: $currentStatus');
    
    // Copy status before toggling for potential rollback
    final previousStatus = currentStatus;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      if (currentStatus != null) {
        // User is currently followed or pending - unfollow them
        print('Attempting to unfollow user $userId');
        
        // Optimistically update UI
        setState(() {
          _followStatus.remove(userId);
        });
        
        // Execute unfollow operation
        await UserService.unfollowUser(currentUser.id, userId);
        
        // Double-check status was updated in database
        await Future.delayed(const Duration(milliseconds: 500)); // Small delay to ensure DB updated
        final followCheck = await UserService.getFollowRequestStatus(currentUser.id, userId);
        
        print('Follow status after unfollow attempt: $followCheck');
        if (followCheck != null) {
          print('WARNING: Follow relationship still exists after unfollow attempt');
          
          // If relationship still exists, revert UI (will be caught in catch block)
          throw Exception('Failed to remove follow relationship');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unfollowed user or canceled request')),
        );
      } else {
        // User is not followed - follow them
        print('Attempting to follow user $userId');
        
        // Optimistically update UI
        setState(() {
          _followStatus[userId] = 'pending';
        });
        
        // Execute follow operation
        await UserService.followUser(currentUser.id, userId);
        
        // Verify follow request was created in database
        await Future.delayed(const Duration(milliseconds: 500)); // Small delay to ensure DB updated
        final followCheck = await UserService.getFollowRequestStatus(currentUser.id, userId);
        
        print('Follow status after follow attempt: $followCheck');
        if (followCheck == null) {
          print('WARNING: No follow relationship found after follow attempt');
          
          // If relationship wasn't created, revert UI (will be caught in catch block)
          throw Exception('Failed to create follow relationship');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Follow request sent')),
        );
      }
    } catch (e) {
      print('ERROR in _toggleFollow: $e');
      
      // Revert the UI change on error
      setState(() {
        if (previousStatus != null) {
          // Restore previous status
          _followStatus[userId] = previousStatus;
        } else {
          // Remove pending status
          _followStatus.remove(userId);
        }
      });

      // Show a more detailed error message with troubleshooting help
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Follow action failed: ${e.toString()}'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Help',
            onPressed: () {
              SupabaseHelper.showSupabaseTroubleshootingDialog(context);
            },
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _handleFollowRequest(String userId, bool accept) async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (accept) {
        await UserService.acceptFollowRequest(userId, currentUser.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Follow request accepted')),
        );
      } else {
        await UserService.rejectFollowRequest(userId, currentUser.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Follow request rejected')),
        );
      }
      
      // Reload data after handling the request
      await _loadUsers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process follow request: ${e.toString()}')),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF8A2BE2),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF8A2BE2),
          tabs: [
            Tab(
              text: 'All Users',
              icon: Badge(
                isLabelVisible: false,
                child: const Icon(Icons.people),
              ),
            ),
            Tab(
              text: 'Follow Requests',
              icon: Badge(
                isLabelVisible: _followRequestUsers.isNotEmpty,
                label: Text(_followRequestUsers.length.toString()),
                child: const Icon(Icons.person_add),
              ),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Users Tab
          Column(
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
                                    final followStatus = _followStatus[user.id];
                                    
                                    // Determine button text and style based on follow status
                                    String buttonText;
                                    Color buttonColor;
                                    
                                    if (followStatus == 'pending') {
                                      buttonText = 'Requested';
                                      buttonColor = Colors.orange;
                                    } else if (followStatus == 'accepted') {
                                      buttonText = 'Following';
                                      buttonColor = Colors.green;
                                    } else {
                                      buttonText = 'Follow';
                                      buttonColor = const Color(0xFF8A2BE2);
                                    }
                                    
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
                                                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
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
                                            foregroundColor: buttonColor,
                                            side: BorderSide(color: buttonColor),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          child: Text(buttonText),
                                        ),
                                        onTap: () {
                                          // Navigate to user detail screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserDetailScreen(user: user),
                                            ),
                                          ).then((_) => _loadUsers()); // Reload after returning
                                        },
                                      ),
                                    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index));
                                  },
                                ),
                              ),
              ),
            ],
          ),
          
          // Follow Requests Tab
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF8A2BE2)))
              : _followRequestUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_add_disabled, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No pending follow requests',
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
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        itemCount: _followRequestUsers.length,
                        itemBuilder: (context, index) {
                          final user = _followRequestUsers[index];
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFF8A2BE2),
                                        backgroundImage: user.avatarUrl != null
                                            ? NetworkImage(user.avatarUrl!)
                                            : null,
                                        radius: 28,
                                        child: user.avatarUrl == null
                                            ? Text(
                                                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.fullName,
                                              style: GoogleFonts.nunito(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (user.bio != null)
                                              Text(
                                                user.bio!,
                                                style: GoogleFonts.nunito(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _handleFollowRequest(user.id, false),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: const BorderSide(color: Colors.red),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _handleFollowRequest(user.id, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF8A2BE2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          child: const Text('Accept'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserDetailScreen(user: user),
                                          ),
                                        ).then((_) => _loadUsers());
                                      },
                                      child: Text(
                                        'View Profile',
                                        style: GoogleFonts.nunito(
                                          color: const Color(0xFF8A2BE2),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * index));
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
