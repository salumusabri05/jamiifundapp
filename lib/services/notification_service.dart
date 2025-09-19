import 'dart:async';
import 'package:jamiifund/models/notification_model.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  // Supabase client
  static SupabaseClient get _supabase => SupabaseService.client;
  static const String _notificationsTable = 'notifications';
  
  // Stream controller for notifications
  static final _notificationStreamController = StreamController<List<NotificationModel>>.broadcast();
  
  // Get all notifications for the current user
  static Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final response = await _supabase
          .from(_notificationsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((data) => NotificationModel.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }
  
  // Mark a notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from(_notificationsTable)
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
      
      // Refresh the stream with updated data
      refreshNotifications();
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
  
  // Mark all notifications as read
  static Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from(_notificationsTable)
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);
      
      // Refresh the stream with updated data
      refreshNotifications();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }
  
  // Delete a notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from(_notificationsTable)
          .delete()
          .eq('id', notificationId);
      
      // Refresh the stream with updated data
      refreshNotifications();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }
  
  // Subscribe to new notifications
  static Stream<List<NotificationModel>> subscribeToNotifications(String userId) {
    // Initial data
    refreshNotifications(userId);
    
    // Set up Supabase realtime subscription
    final channel = _supabase.channel('public:notifications:$userId');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: _notificationsTable,
      filter: 'user_id=eq.$userId' as PostgresChangeFilter,
      callback: (payload) {
        // Refresh all notifications when any change happens
        refreshNotifications(userId);
      },
    );
    
    channel.subscribe();
    
    // Return the stream
    return _notificationStreamController.stream;
  }
  
  // Get unread notification count
  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final response = await _supabase
          .from(_notificationsTable)
          .select()
          .eq('user_id', userId)
          .eq('is_read', false);
      
      return (response as List<dynamic>).length;
    } catch (e) {
      throw Exception('Failed to get unread notification count: $e');
    }
  }
  
  // Create a new notification
  static Future<NotificationModel> createNotification({
    required String userId,
    required String title,
    String? body,
    String type = 'info',
    String? action,
    String? resourceId,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        body: body,
        type: type,
        action: action,
        resourceId: resourceId,
        isRead: false,
        createdAt: DateTime.now(),
      );
      
      final response = await _supabase
          .from(_notificationsTable)
          .insert(notification.toMap())
          .select()
          .single();
      
      final createdNotification = NotificationModel.fromMap(response);
      
      // Refresh the stream with updated data
      refreshNotifications();
      
      return createdNotification;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }
  
  // Helper method to refresh notifications
  static void refreshNotifications([String? userId]) async {
    if (userId != null) {
      try {
        final notifications = await getUserNotifications(userId);
        _notificationStreamController.add(notifications);
      } catch (e) {
        // If there's an error, add an empty list
        _notificationStreamController.add([]);
      }
    }
  }
}
