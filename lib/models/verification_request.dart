class VerificationRequest {
  final String? id;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String idDocumentUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VerificationRequest({
    this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.idDocumentUrl,
    this.status = 'pending',
    this.rejectionReason,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address': address,
      'id_document_url': idDocumentUrl,
      'status': status,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static VerificationRequest fromMap(Map<String, dynamic> map) {
    return VerificationRequest(
      id: map['id'],
      userId: map['user_id'],
      fullName: map['full_name'],
      phoneNumber: map['phone_number'],
      address: map['address'],
      idDocumentUrl: map['id_document_url'],
      status: map['status'],
      rejectionReason: map['rejection_reason'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  VerificationRequest copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? idDocumentUrl,
    String? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
