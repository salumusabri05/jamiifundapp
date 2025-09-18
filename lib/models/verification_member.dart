class VerificationMember {
  final String? id;
  final String? verificationId;
  final String fullName;
  final String role;
  final String? dateOfBirth;
  final String? nationalId;
  final String? email;
  final String? phone;
  final String? selfieUrl;
  final String? idDocumentUrl;
  final String status; // 'pending', 'submitted', 'completed'
  
  const VerificationMember({
    this.id,
    this.verificationId,
    required this.fullName,
    required this.role,
    this.dateOfBirth,
    this.nationalId,
    this.email,
    this.phone,
    this.selfieUrl,
    this.idDocumentUrl,
    this.status = 'pending',
  });
  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (verificationId != null) 'verification_id': verificationId,
      'full_name': fullName,
      'role': role,
      'date_of_birth': dateOfBirth,
      'national_id': nationalId,
      'email': email,
      'phone': phone,
      'selfie_url': selfieUrl,
      'id_document_url': idDocumentUrl,
      'status': status,
    };
  }
  
  static VerificationMember fromMap(Map<String, dynamic> map) {
    return VerificationMember(
      id: map['id'],
      verificationId: map['verification_id'],
      fullName: map['full_name'] ?? '',
      role: map['role'] ?? '',
      dateOfBirth: map['date_of_birth'],
      nationalId: map['national_id'],
      email: map['email'],
      phone: map['phone'],
      selfieUrl: map['selfie_url'],
      idDocumentUrl: map['id_document_url'],
      status: map['status'] ?? 'pending',
    );
  }
  
  VerificationMember copyWith({
    String? id,
    String? verificationId,
    String? fullName,
    String? role,
    String? dateOfBirth,
    String? nationalId,
    String? email,
    String? phone,
    String? selfieUrl,
    String? idDocumentUrl,
    String? status,
  }) {
    return VerificationMember(
      id: id ?? this.id,
      verificationId: verificationId ?? this.verificationId,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationalId: nationalId ?? this.nationalId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      status: status ?? this.status,
    );
  }
}
