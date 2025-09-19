import 'package:jamiifund/models/message.dart';

class ChatRoom {
  final String id;
  final String? name;
  final bool isGroup;
  final String createdBy;
  final DateTime createdAt;
  
  // Additional fields for UI
  String? lastMessage;
  DateTime? lastMessageTime;
  int unreadCount = 0;
  List<String> members = [];
  
  ChatRoom({
    required this.id,
    this.name,
    required this.isGroup,
    required this.createdBy,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });
  
  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] as String,
      name: map['name'] as String?,
      isGroup: map['is_group'] as bool,
      createdBy: map['created_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastMessage: map['last_message'] as String?,
      lastMessageTime: map['last_message_time'] != null 
        ? DateTime.parse(map['last_message_time'] as String) 
        : null,
      unreadCount: map['unread_count'] as int? ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_group': isGroup,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
