import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamiifund/models/notification_model.dart';
import 'package:jamiifund/services/notification_service.dart';
import 'package:jamiifund/services/user_service.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'You must be logged in to view notifications';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await NotificationService.getUserNotifications(currentUser.id);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load notifications: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      setState(() {
        _notifications = _notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark notification as read: ${e.toString()}')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    final currentUser = UserService.getCurrentUser();
    if (currentUser == null) return;

    try {
      await NotificationService.markAllAsRead(currentUser.id);
      setState(() {
        _notifications = _notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark all as read: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      setState(() {
        _notifications = _notifications.where((notification) => notification.id != notificationId).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete notification: ${e.toString()}')),
      );
    }
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          if (_notifications.any((notification) => !notification.isRead))
            IconButton(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all),
              color: const Color(0xFF8A2BE2),
              tooltip: 'Mark all as read',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                // TODO: Navigate to notification settings
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Notification Settings'),
              ),
            ],
            icon: Icon(
              Icons.more_vert,
              color: const Color(0xFF8A2BE2),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0), // Using home index since notifications is accessed from menu
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        color: const Color(0xFF8A2BE2),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadNotifications,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A2BE2),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something happens',
            style: GoogleFonts.nunito(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A2BE2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationTile(notification);
      },
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    final iconData = _getIconForType(notification.type);
    final iconColor = _getIconColorForType(notification.type);
    final backgroundColor = notification.isRead ? Colors.white : Colors.purple[50];
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification.id);
            }
            
            // Handle notification action
            if (notification.action != null) {
              // TODO: Implement navigation based on notification action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Action: ${notification.action}')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.nunito(
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            _getTimeAgo(notification.createdAt),
                            style: GoogleFonts.nunito(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (notification.body != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.body!,
                          style: GoogleFonts.nunito(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (!notification.isRead) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _markAsRead(notification.id),
                              child: Text(
                                'Mark as read',
                                style: GoogleFonts.nunito(
                                  color: const Color(0xFF8A2BE2),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
  
  IconData _getIconForType(String type) {
    switch (type) {
      case 'campaign':
        return Icons.campaign;
      case 'donation':
        return Icons.volunteer_activism;
      case 'comment':
        return Icons.comment;
      case 'message':
        return Icons.message;
      case 'update':
        return Icons.update;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
  
  Color _getIconColorForType(String type) {
    switch (type) {
      case 'campaign':
        return Colors.green;
      case 'donation':
        return Colors.orange;
      case 'comment':
        return Colors.blue;
      case 'message':
        return Colors.purple;
      case 'update':
        return Colors.amber;
      case 'system':
        return Colors.grey;
      default:
        return const Color(0xFF8A2BE2);
    }
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
