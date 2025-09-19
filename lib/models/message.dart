class Message {
  final String id;
  final String roomId;
  final String senderId;
  final String? content;
  final List<MediaItem>? media;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  
  // Additional fields for UI
  String? senderName;
  String? senderAvatar;
  bool isRead = false;
  List<String> readBy = [];
  
  Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.content,
    this.media,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
    this.senderName,
    this.senderAvatar,
    this.isRead = false,
  });
  
  factory Message.fromMap(Map<String, dynamic> map) {
    List<MediaItem>? mediaItems;
    if (map['media'] != null) {
      mediaItems = (map['media'] as List).map((item) => MediaItem.fromMap(item)).toList();
    }
    
    return Message(
      id: map['id'].toString(),
      roomId: map['room_id'] as String,
      senderId: map['sender_id'] as String,
      content: map['content'] as String?,
      media: mediaItems,
      createdAt: DateTime.parse(map['created_at'] as String),
      editedAt: map['edited_at'] != null ? DateTime.parse(map['edited_at'] as String) : null,
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
      senderName: map['sender_name'] as String?,
      senderAvatar: map['sender_avatar'] as String?,
      isRead: map['is_read'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'media': media?.map((e) => e.toMap()).toList(),
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
  
  bool get isDeleted => deletedAt != null;
  bool get isEdited => editedAt != null;
  bool get hasMedia => media != null && media!.isNotEmpty;
}

class MediaItem {
  final String type; // image, video, etc.
  final String url;
  final String? thumbnail;
  
  MediaItem({
    required this.type,
    required this.url,
    this.thumbnail,
  });
  
  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      type: map['type'] as String,
      url: map['url'] as String,
      thumbnail: map['thumbnail'] as String?,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'url': url,
      if (thumbnail != null) 'thumbnail': thumbnail,
    };
  }
}
