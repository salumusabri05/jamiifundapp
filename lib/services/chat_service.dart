import 'package:image_picker/image_picker.dart';
import 'package:jamiifund/models/chat_room.dart';
import 'package:jamiifund/models/message.dart';
import 'package:jamiifund/models/user_profile.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:jamiifund/services/user_service.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  static const String _chatRoomsTable = 'chat_rooms';
  static const String _messagesTable = 'messages';
  static const String _participantsTable = 'chat_participants';
  static const String _messageReadsTable = 'message_reads';
  static const String _storageBucket = 'chat_media';
  
  // Get Supabase client
  static SupabaseClient get _client => SupabaseService.client;
  
  // Listeners for real-time updates
  static final List<Function(Message)> _messageListeners = [];
  static final List<Function(List<ChatRoom>)> _roomListeners = [];

  // Get all chat rooms for the current user
  static Future<List<ChatRoom>> getUserChatRooms(String userId) async {
    try {
      // Get room IDs that the user is a participant in
      final participantsResponse = await _client
          .from(_participantsTable)
          .select('room_id')
          .eq('user_id', userId);
      
      List<String> roomIds = (participantsResponse as List)
          .map((item) => item['room_id'].toString())
          .toList();
      
      if (roomIds.isEmpty) {
        return [];
      }
      
      // Get the chat rooms
      final roomsResponse = await _client
          .from(_chatRoomsTable)
          .select()
          .inFilter('id', roomIds)
          .order('last_message_at', ascending: false);
      
      return (roomsResponse as List).map((item) => ChatRoom.fromMap(item)).toList();
    } catch (e) {
      // Handle errors - fallback to empty list if not found
      return [];
    }
  }
  
  // Get unread messages count for a user
  static Future<int> getUnreadMessagesCount(String userId) async {
    try {
      // Get all rooms where the user is a participant
      final userRooms = await getUserChatRooms(userId);
      if (userRooms.isEmpty) return 0;
      
      // Get room IDs
      final roomIds = userRooms.map((room) => room.id).toList();
      
      // Get user's read state for each room
      final readResponse = await _client
          .from(_messageReadsTable)
          .select('room_id, last_read_at')
          .eq('user_id', userId)
          .inFilter('room_id', roomIds);
      
      // Create a map of room ID to last read timestamp
      final Map<String, DateTime?> lastReadMap = {};
      for (final item in readResponse as List) {
        lastReadMap[item['room_id']] = item['last_read_at'] != null 
            ? DateTime.parse(item['last_read_at']) 
            : null;
      }
      
      int totalUnread = 0;
      
      // For each room, count messages after the last read timestamp
      for (final roomId in roomIds) {
        final lastRead = lastReadMap[roomId];
        
        // Query to count unread messages
        final query = _client
            .from(_messagesTable)
            .select()
            .eq('room_id', roomId)
            .neq('sender_id', userId); // Don't count user's own messages
        
        // Add timestamp filter if we have a last read time
        if (lastRead != null) {
          query.gt('created_at', lastRead.toIso8601String());
        }
        
        final countResponse = await query;
        totalUnread += (countResponse as List).length;
      }
      
      return totalUnread;
    } catch (e) {
      print('Error getting unread messages count: $e');
      return 0;
    }
  }
  
  // Get messages for a specific room
  static Future<List<Message>> getRoomMessages(String roomId) async {
    try {
      final response = await _client
          .from(_messagesTable)
          .select()
          .eq('room_id', roomId)
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => Message.fromMap(item)).toList();
    } catch (e) {
      // Handle errors - fallback to empty list if not found
      return [];
    }
  }
  
  // Upload media files for a message
  static Future<List<MediaItem>> uploadMessageMedia(List<XFile> files, String userId) async {
    try {
      List<MediaItem> mediaItems = [];
      
      for (var file in files) {
        final fileBytes = await file.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}-${path.basename(file.path)}';
        final filePath = '$userId/$fileName';
        
        // Upload file to Supabase storage
        final response = await _client
            .storage
            .from(_storageBucket)
            .uploadBinary(filePath, fileBytes);
        
        if (response.isEmpty) {
          throw Exception('Failed to upload file');
        }
        
        // Get public URL for the file
        final url = _client
            .storage
            .from(_storageBucket)
            .getPublicUrl(filePath);
        
        // Generate thumbnail URL (in real app, you'd resize image)
        final thumbnail = url;
        
        mediaItems.add(MediaItem(
          type: 'image', // Determine from file.mimeType
          url: url,
          thumbnail: thumbnail,
        ));
      }
      
      return mediaItems;
    } catch (e) {
      // If upload fails, throw exception instead of using mock data
      throw Exception('Failed to upload media files: $e');
    }
  }

  // Send a new message
  static Future<Message> sendMessage({
    required String roomId,
    required String senderId,
    String? content,
    List<XFile>? mediaFiles,
    List<MediaItem>? media,
  }) async {
    try {
      // Process media files if provided
      List<MediaItem> messageMedia = media ?? [];
      
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        messageMedia = await uploadMessageMedia(mediaFiles, senderId);
      }
      
      // Create the message
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: roomId,
        senderId: senderId,
        content: content ?? '',
        media: messageMedia,
        createdAt: DateTime.now(),
      );
      
      // Store the message in Supabase
      final response = await _client
          .from(_messagesTable)
          .insert(message.toMap())
          .select()
          .single();
      
      final sentMessage = Message.fromMap(response);
      
      // Update the room's last message time
      await _client
          .from(_chatRoomsTable)
          .update({
            'last_message_at': DateTime.now().toIso8601String(),
            'last_message': content ?? (messageMedia.isNotEmpty ? 'Media message' : ''),
          })
          .eq('id', roomId);
      
      // Notify listeners
      for (var listener in _messageListeners) {
        listener(sentMessage);
      }
      
      return sentMessage;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
    
    // Dead code removed
  }
  
  // Create a new chat room
  static Future<ChatRoom> createChatRoom({
    required String createdBy,
    required List<String> memberIds,
    String? name,
    bool isGroup = false,
  }) async {
    try {
      // Create chat room in Supabase
      final Map<String, dynamic> roomData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': isGroup ? name : null,
        'is_group': isGroup,
        'created_by': createdBy,
        'created_at': DateTime.now().toIso8601String(),
        'last_message': null,
        'last_message_at': DateTime.now().toIso8601String(),
      };
      
      // Insert the room
      final roomResponse = await _client
          .from(_chatRoomsTable)
          .insert(roomData)
          .select()
          .single();
      
      final room = ChatRoom.fromMap(roomResponse);
      
      // Add participants
      List<Map<String, dynamic>> participants = [];
      for (String memberId in memberIds) {
        participants.add({
          'room_id': room.id,
          'user_id': memberId,
          'joined_at': DateTime.now().toIso8601String(),
        });
      }
      
      await _client
          .from(_participantsTable)
          .insert(participants);
      
      // Notify listeners about new room
      final updatedRooms = await getUserChatRooms(createdBy);
      for (final listener in _roomListeners) {
        listener(updatedRooms);
      }
      
      return room;
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }
  
  // Mark messages as read
  static Future<void> markMessagesAsRead({
    required String roomId,
    required String userId,
  }) async {
    try {
      // Get unread messages in this room
      final response = await _client
          .from(_messageReadsTable)
          .select('message_id')
          .eq('user_id', userId)
          .eq('room_id', roomId);
      
      final readMessageIds = (response as List).map((item) => item['message_id'].toString()).toList();
      
      // Get messages that need to be marked as read
      final unreadMessages = await _client
          .from(_messagesTable)
          .select('id')
          .eq('room_id', roomId)
          .not('id', 'in', readMessageIds)
          .neq('sender_id', userId); // Don't mark your own messages
      
      if ((unreadMessages as List).isNotEmpty) {
        // Create read records for each message
        List<Map<String, dynamic>> readRecords = [];
        for (var msg in unreadMessages) {
          readRecords.add({
            'user_id': userId,
            'message_id': msg['id'],
            'room_id': roomId,
            'read_at': DateTime.now().toIso8601String(),
          });
        }
        
        // Insert read records
        await _client.from(_messageReadsTable).insert(readRecords);
        
        // Update room's unread count (if you have that field in your schema)
        await _client
            .from(_chatRoomsTable)
            .update({'unread_count': 0})
            .eq('id', roomId);
      }
      
      // Get updated rooms and notify listeners
      final updatedRooms = await getUserChatRooms(userId);
      for (final listener in _roomListeners) {
        listener(updatedRooms);
      }
    } catch (e) {
      // Silently handle error
      print('Error marking messages as read: $e');
    }
  }
  
  // Subscribe to new messages
  static Function subscribeToRoomMessages(String roomId, Function(Message) onMessage) {
    // Add listener to our local list
    _messageListeners.add(onMessage);
    
    // Set up Supabase realtime subscription for messages
    final channel = _client.channel('public:messages:$roomId');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: _messagesTable,
      filter: 'room_id=eq.$roomId' as PostgresChangeFilter,
      callback: (payload) {
        // Convert payload to Message and notify
        final message = Message.fromMap(payload.newRecord);
        onMessage(message);
      },
    );
    
    channel.subscribe();
    
    // Return unsubscribe function
    return () {
      _messageListeners.remove(onMessage);
      channel.unsubscribe();
    };
  }
  
  // Subscribe to chat room updates
  static Function subscribeToRooms(Function(List<ChatRoom>) onRoomsUpdate) {
    // Add listener to our local list
    _roomListeners.add(onRoomsUpdate);
    
    // Set up Supabase realtime subscription for chat rooms
    final channel = _client.channel('public:chat_rooms');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: _chatRoomsTable,
      callback: (payload) async {
        // Get updated rooms and notify
        final userId = _client.auth.currentUser?.id;
        if (userId != null) {
          final updatedRooms = await getUserChatRooms(userId);
          onRoomsUpdate(updatedRooms);
        }
      },
    );
    
    channel.subscribe();
    
    // Return unsubscribe function
    return () {
      _roomListeners.remove(onRoomsUpdate);
      channel.unsubscribe();
    };
  }
  
  // Get or create a direct chat room between two users
  static Future<String> getOrCreateChatRoom(String userId1, String userId2) async {
    try {
      // Sort user IDs to ensure consistent room creation
      final List<String> sortedIds = [userId1, userId2]..sort();
      final roomKey = '${sortedIds[0]}_${sortedIds[1]}';
      
      // Check if a direct chat room already exists between these users
      final existingRooms = await _client
          .from(_chatRoomsTable)
          .select('id')
          .eq('room_key', roomKey)
          .limit(1);
      
      // If room exists, return it
      if (existingRooms.isNotEmpty) {
        return existingRooms[0]['id'];
      }
      
      // Create a new direct chat room
      final roomId = DateTime.now().millisecondsSinceEpoch.toString();
      await _client
          .from(_chatRoomsTable)
          .insert({
            'id': roomId,
            'is_group': false,
            'room_key': roomKey,
            'created_by': userId1,
            'created_at': DateTime.now().toIso8601String(),
            'last_message_at': DateTime.now().toIso8601String(),
          });
      
      // Add both users as participants
      await _client
          .from(_participantsTable)
          .insert([
            {
              'room_id': roomId,
              'user_id': userId1,
              'joined_at': DateTime.now().toIso8601String(),
            },
            {
              'room_id': roomId,
              'user_id': userId2,
              'joined_at': DateTime.now().toIso8601String(),
            },
          ]);
      
      return roomId;
    } catch (e) {
      throw Exception('Failed to get or create chat room: $e');
    }
  }
  
  // Get chat messages for a specific chat room
  static Future<List<Message>> getChatMessages(String chatRoomId) async {
    try {
      final response = await _client
          .from(_messagesTable)
          .select()
          .eq('room_id', chatRoomId)
          .order('created_at');
      
      return (response as List).map((item) => Message.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to get chat messages: $e');
    }
  }
  
  // Send a direct message to another user
  static Future<void> sendDirectMessage(
    String chatRoomId,
    String senderId,
    String receiverId,
    String content,
  ) async {
    try {
      // Create message
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Insert message
      await _client
          .from(_messagesTable)
          .insert({
            'id': messageId,
            'room_id': chatRoomId,
            'sender_id': senderId,
            'receiver_id': receiverId,
            'content': content,
            'created_at': DateTime.now().toIso8601String(),
            'is_read': false,
          });
      
      // Update chat room with last message info
      await _client
          .from(_chatRoomsTable)
          .update({
            'last_message': content,
            'last_message_at': DateTime.now().toIso8601String(),
          })
          .eq('id', chatRoomId);
          
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
  
  // Mark all messages in a chat room as read for a user
  static Future<void> markDirectMessagesAsRead(String chatRoomId, String userId) async {
    try {
      // Update all unread messages received by this user in this room
      await _client
          .from(_messagesTable)
          .update({'is_read': true})
          .eq('room_id', chatRoomId)
          .eq('receiver_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
  
  // Subscribe to new messages in a specific chat room
  static Function subscribeToMessages(String chatRoomId, Function(Message) onNewMessage) {
    final channel = _client.channel('public:messages:$chatRoomId');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: _messagesTable,
      filter: 'room_id=eq.$chatRoomId' as PostgresChangeFilter,
      callback: (payload) {
        final message = Message.fromMap(payload.newRecord);
        onNewMessage(message);
      },
    );
    
    channel.subscribe();
    
    // Return unsubscribe function
    return () {
      channel.unsubscribe();
    };
  }
}
