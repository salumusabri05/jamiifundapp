class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String? body;
  final String type;
  final String? action;
  final String? resourceId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  
  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    this.body,
    required this.type,
    this.action,
    this.resourceId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });
  
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      body: map['body'] as String?,
      type: map['type'] as String? ?? 'info',
      action: map['action'] as String?,
      resourceId: map['resource_id'] as String?,
      isRead: map['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      readAt: map['read_at'] != null ? DateTime.parse(map['read_at'] as String) : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'action': action,
      'resource_id': resourceId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }
  
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    String? action,
    String? resourceId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      action: action ?? this.action,
      resourceId: resourceId ?? this.resourceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
