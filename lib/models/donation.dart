class Donation {
  final String id;
  final String campaignId;
  final String? userId;
  final double amount;
  final String? donorName;
  final String? donorEmail;
  final String? message;
  final bool anonymous;
  final DateTime createdAt;
  
  // Additional fields for payment processing (not stored in DB)
  final String? paymentMethod;
  final String? paymentIntentId;
  final String? paymentStatus;

  Donation({
    String? id,
    required this.campaignId,
    this.userId,
    required this.amount,
    this.donorName,
    this.donorEmail,
    this.message,
    this.anonymous = false,
    DateTime? createdAt,
    this.paymentMethod,
    this.paymentIntentId,
    this.paymentStatus,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  // Create from JSON
  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      campaignId: json['campaign_id'],
      userId: json['user_id'],
      amount: json['amount'] is int 
          ? (json['amount'] as int).toDouble() 
          : json['amount'],
      donorName: json['donor_name'],
      donorEmail: json['donor_email'],
      message: json['message'],
      anonymous: json['anonymous'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      paymentMethod: json['payment_method'],
      paymentIntentId: json['payment_intent_id'],
      paymentStatus: json['payment_status'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'user_id': userId,
      'amount': amount,
      'donor_name': donorName,
      'donor_email': donorEmail,
      'message': message,
      'anonymous': anonymous,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a copy of this donation with new values
  Donation copyWith({
    String? id,
    String? campaignId,
    String? userId,
    double? amount,
    String? donorName,
    String? donorEmail,
    String? message,
    bool? anonymous,
    DateTime? createdAt,
    String? paymentMethod,
    String? paymentIntentId,
    String? paymentStatus,
  }) {
    return Donation(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      donorName: donorName ?? this.donorName,
      donorEmail: donorEmail ?? this.donorEmail,
      message: message ?? this.message,
      anonymous: anonymous ?? this.anonymous,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}
