import 'dart:convert';

class Campaign {
  final String id;
  final DateTime? createdAt;
  final String title;
  final String description;
  final String category;
  final int goalAmount;
  int currentAmount;
  final DateTime endDate;
  String? imageUrl;
  final String? createdBy;
  bool isFeatured;
  int donorCount;
  String? createdByName;
  String? firebaseUid;

  Campaign({
    required this.id,
    this.createdAt,
    required this.title,
    required this.description,
    required this.category,
    required this.goalAmount,
    this.currentAmount = 0,
    required this.endDate,
    this.imageUrl,
    this.createdBy,
    this.isFeatured = false,
    this.donorCount = 0,
    this.createdByName,
    this.firebaseUid,
  });

  // Calculate progress percentage
  double get progressPercentage {
    if (goalAmount == 0) return 0;
    return (currentAmount / goalAmount) * 100;
  }

  // Calculate days left until end date
  int get daysLeft {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  // Check if campaign is active
  bool get isActive {
    final now = DateTime.now();
    return endDate.isAfter(now) && currentAmount < goalAmount;
  }

  // Check if campaign is successful
  bool get isSuccessful {
    return currentAmount >= goalAmount;
  }

  // Check if campaign has expired
  bool get isExpired {
    final now = DateTime.now();
    return endDate.isBefore(now);
  }

  // Convert Campaign to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'title': title,
      'description': description,
      'category': category,
      'goal_amount': goalAmount,
      'current_amount': currentAmount,
      'end_date': "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
      'image_url': imageUrl,
      'created_by': createdBy,
      'is_featured': isFeatured,
      'donor_count': donorCount,
      'created_by_name': createdByName,
      'firebase_uid': firebaseUid,
    };
  }

  // Convert Map to Campaign
  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'] ?? '',
      createdAt: map['created_at'] != null ? 
        DateTime.parse(map['created_at']) : null,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      goalAmount: map['goal_amount']?.toInt() ?? 0,
      currentAmount: map['current_amount']?.toInt() ?? 0,
      endDate: map['end_date'] != null ? 
        (map['end_date'] is String ? 
          DateTime.parse(map['end_date']) : 
          (map['end_date'] as DateTime)) : 
        DateTime.now().add(const Duration(days: 30)),
      imageUrl: map['image_url'],
      createdBy: map['created_by'],
      isFeatured: map['is_featured'] ?? false,
      donorCount: map['donor_count']?.toInt() ?? 0,
      createdByName: map['created_by_name'],
      firebaseUid: map['firebase_uid'],
    );
  }

  // Convert Campaign to JSON string
  String toJson() => json.encode(toMap());

  // Create Campaign from JSON string
  factory Campaign.fromJson(String source) => Campaign.fromMap(json.decode(source));

  // Create a copy of the Campaign with optional updated fields
  Campaign copyWith({
    String? id,
    DateTime? createdAt,
    String? title,
    String? description,
    String? category,
    int? goalAmount,
    int? currentAmount,
    DateTime? endDate,
    String? imageUrl,
    String? createdBy,
    bool? isFeatured,
    int? donorCount,
    String? createdByName,
    String? firebaseUid,
  }) {
    return Campaign(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      goalAmount: goalAmount ?? this.goalAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      isFeatured: isFeatured ?? this.isFeatured,
      donorCount: donorCount ?? this.donorCount,
      createdByName: createdByName ?? this.createdByName,
      firebaseUid: firebaseUid ?? this.firebaseUid,
    );
  }

  @override
  String toString() {
    return 'Campaign(id: $id, title: $title, category: $category, goalAmount: $goalAmount, currentAmount: $currentAmount, progress: ${progressPercentage.toStringAsFixed(1)}%, daysLeft: $daysLeft)';
  }
}
