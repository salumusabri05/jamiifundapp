import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamiifund/models/user_profile.dart';
import 'package:jamiifund/screens/chat_detail_screen.dart';
import 'package:jamiifund/services/user_service.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class UserDetailScreen extends StatefulWidget {
  final UserProfile user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _isFollowing = false;
  bool _isPendingRequest = false; // Added for follow requests
  bool _hasPendingRequestFromUser = false; // To track if the user has sent a follow request to current user
  bool _isFollower = false;
  bool _isMutualFollow = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get follow status between current user and profile user
      final followStatus = await UserService.getFollowRequestStatus(currentUser.id, widget.user.id);
      final isFollowing = followStatus == 'accepted';
      final isPending = followStatus == 'pending';
      
      // Check if the profile user follows the current user (is a follower)
      final followerStatus = await UserService.getFollowRequestStatus(widget.user.id, currentUser.id);
      final isFollower = followerStatus == 'accepted';
      final hasPendingRequest = followerStatus == 'pending';
      
      // Mutual follow means both users follow each other with accepted status
      final isMutual = isFollowing && isFollower;

      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
          _isPendingRequest = isPending;
          _hasPendingRequestFromUser = hasPendingRequest;
          _isFollower = isFollower;
          _isMutualFollow = isMutual;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to check follow status: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
      
      // Toggle state based on current state
      if (_isFollowing) {
        _isFollowing = false;
        _isPendingRequest = false;
      } else if (_isPendingRequest) {
        _isPendingRequest = false;
      } else {
        _isPendingRequest = true;
      }
    });

    try {
      if (_isPendingRequest) {
        await UserService.followUser(currentUser.id, widget.user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Follow request sent to ${widget.user.fullName}')),
        );
      } else {
        await UserService.unfollowUser(currentUser.id, widget.user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unfollowed ${widget.user.fullName}')),
        );
      }
      
      // Refresh status
      _checkFollowStatus();
    } catch (e) {
      // Revert the UI change on error
      setState(() {
        _errorMessage = 'Failed to update follow status: ${e.toString()}';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }
  
  Future<void> _acceptFollowRequest() async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await UserService.acceptFollowRequest(widget.user.id, currentUser.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Accepted follow request from ${widget.user.fullName}')),
      );
      
      // Refresh status
      _checkFollowStatus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to accept follow request: ${e.toString()}';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }
  
  Future<void> _rejectFollowRequest() async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await UserService.rejectFollowRequest(widget.user.id, currentUser.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejected follow request from ${widget.user.fullName}')),
      );
      
      // Refresh status
      _checkFollowStatus();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to reject follow request: ${e.toString()}';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  void _startChat() {
    if (!_isMutualFollow) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: !_isFollowing 
            ? const Text('You need to follow this user to start a chat') 
            : !_isFollower 
              ? const Text('This user needs to follow you back before you can chat') 
              : const Text('You need to have a mutual follow relationship to chat'),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(recipient: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF8A2BE2)),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2), // Community tab
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User profile header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Avatar
                  Hero(
                    tag: 'user-avatar-${widget.user.id}',
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF8A2BE2),
                      backgroundImage: widget.user.avatarUrl != null
                          ? NetworkImage(widget.user.avatarUrl!)
                          : null,
                      radius: 60,
                      child: widget.user.avatarUrl == null
                          ? Text(
                              widget.user.fullName.isNotEmpty ? widget.user.fullName[0].toUpperCase() : '?',
                              style: GoogleFonts.nunito(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 300.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Full name
                  Text(
                    widget.user.fullName,
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0, duration: 300.ms),
                  
                  const SizedBox(height: 6),
                  
                  // Username
                  if (widget.user.username != null)
                    Text(
                      '@${widget.user.username}',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.3, end: 0, duration: 300.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Bio
                  if (widget.user.bio != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        widget.user.bio!,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.3, end: 0, duration: 300.ms),
                  
                  const SizedBox(height: 8),
                  
                  // Follow status indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isFollower || _hasPendingRequestFromUser)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _isFollower ? 
                              (_isMutualFollow ? Colors.green[50] : Colors.blue[50]) : 
                              Colors.orange[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isFollower ? 
                                (_isMutualFollow ? Colors.green : Colors.blue) : 
                                Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _isFollower ? 
                              (_isMutualFollow ? 'Mutual Followers' : 'Follows You') : 
                              'Requested to Follow You',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: _isFollower ? 
                                (_isMutualFollow ? Colors.green[700] : Colors.blue[700]) : 
                                Colors.orange[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      
                      if (_isPendingRequest)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Follow Requested',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Follow/Unfollow button
                      _hasPendingRequestFromUser 
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: _isLoading ? null : _acceptFollowRequest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Accept',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _rejectFollowRequest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Reject',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ElevatedButton.icon(
                          onPressed: _isLoading ? null : _toggleFollow,
                          icon: Icon(
                            _isFollowing ? Icons.person_remove : 
                            _isPendingRequest ? Icons.hourglass_empty : Icons.person_add,
                            color: Colors.white,
                          ),
                          label: Text(
                            _isFollowing ? 'Unfollow' : 
                            _isPendingRequest ? 'Requested' : 'Follow',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing ? Colors.grey[700] : 
                                             _isPendingRequest ? Colors.orange : 
                                             const Color(0xFF8A2BE2),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      
                      const SizedBox(width: 16),
                      
                      // Message button
                      ElevatedButton.icon(
                        onPressed: _isMutualFollow ? _startChat : null,
                        icon: const Icon(
                          Icons.chat,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Message',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isMutualFollow ? const Color(0xFF4CAF50) : Colors.grey[400],
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
                  
                  if (!_isMutualFollow)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _isFollowing && !_isFollower ? 'Waiting for user to follow you back' :
                        !_isFollowing ? 'You need to follow and be followed to message' :
                        'You need mutual follow to message',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // User details card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A2BE2),
                      ),
                    ),
                    const Divider(),
                    
                    // Email
                    if (widget.user.email != null)
                      _buildInfoRow('Email', widget.user.email!),
                    
                    // Phone
                    if (widget.user.phone != null)
                      _buildInfoRow('Phone', widget.user.phone!),
                    
                    // Location
                    if (widget.user.location != null)
                      _buildInfoRow('Location', widget.user.location!),
                    
                    // Website
                    if (widget.user.website != null)
                      _buildInfoRow('Website', widget.user.website!),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
            
            // Organization details if applicable
            if (widget.user.isOrganization ?? false)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organization Details',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8A2BE2),
                        ),
                      ),
                      const Divider(),
                      
                      // Organization name
                      if (widget.user.organizationName != null)
                        _buildInfoRow('Name', widget.user.organizationName!),
                      
                      // Organization type
                      if (widget.user.organizationType != null)
                        _buildInfoRow('Type', widget.user.organizationType!),
                      
                      // Registration number
                      if (widget.user.organizationRegNumber != null)
                        _buildInfoRow('Registration', widget.user.organizationRegNumber!),
                      
                      // Organization description
                      if (widget.user.organizationDescription != null)
                        _buildInfoRow('About', widget.user.organizationDescription!, isMultiLine: true),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 600.ms),
            
            // Address card
            if (widget.user.address != null || widget.user.city != null || 
                widget.user.region != null || widget.user.postalCode != null)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8A2BE2),
                        ),
                      ),
                      const Divider(),
                      
                      if (widget.user.address != null)
                        _buildInfoRow('Street', widget.user.address!),
                      
                      if (widget.user.city != null)
                        _buildInfoRow('City', widget.user.city!),
                      
                      if (widget.user.region != null)
                        _buildInfoRow('Region', widget.user.region!),
                      
                      if (widget.user.postalCode != null)
                        _buildInfoRow('Postal Code', widget.user.postalCode!),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 700.ms),
              
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
