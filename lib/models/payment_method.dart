class PaymentMethod {
  final String? id;
  final String userId;
  final String type; // 'mobile_money', 'bank', etc.
  final String accountNumber;
  final String accountName;
  final DateTime createdAt;

  PaymentMethod({
    this.id,
    required this.userId,
    required this.type,
    required this.accountNumber,
    required this.accountName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'type': type,
      'account_number': accountNumber,
      'account_name': accountName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static PaymentMethod fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      userId: map['user_id'],
      type: map['type'],
      accountNumber: map['account_number'],
      accountName: map['account_name'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}
