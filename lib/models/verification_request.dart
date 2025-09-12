class VerificationRequest {
  final String? id;
  final String? userId;
  final String? documentType; // Type of verification document (ID, Passport, etc.)
  final String? idUrl;        // URL to the uploaded ID document
  final String status;        // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final String? notes;        // Additional notes for verification
  final DateTime createdAt;
  final DateTime? updatedAt;

  VerificationRequest({
    this.id,
    this.userId,
    this.documentType,
    this.idUrl,
    this.status = 'pending',
    this.rejectionReason,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (documentType != null) 'document_type': documentType,
      if (idUrl != null) 'id_url': idUrl,
      'status': status,
      'rejection_reason': rejectionReason,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static VerificationRequest fromMap(Map<String, dynamic> map) {
    return VerificationRequest(
      id: map['id'],
      userId: map['user_id'],
      documentType: map['document_type'],
      idUrl: map['id_url'],
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejection_reason'],
      notes: map['notes'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  VerificationRequest copyWith({
    String? id,
    String? userId,
    String? documentType,
    String? idUrl,
    String? status,
    String? rejectionReason,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      documentType: documentType ?? this.documentType,
      idUrl: idUrl ?? this.idUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
