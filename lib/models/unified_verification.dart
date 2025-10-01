import 'package:flutter/foundation.dart';
import 'package:jamiifund/models/verification_member.dart';

class UnifiedVerification {
  final String? id;
  final String? userId;
  final String status; // 'pending', 'approved', 'rejected'
  
  // Personal KYC data
  final String? fullName;
  final String? dateOfBirth;
  final String? nationalId;
  final String? address;
  final String? phone;
  final String? email;
  final String? selfieUrl;
  final String? idDocumentUrl;
  final String? bankAccount;
  final String? bankName;
  
  // Organization data
  final bool isOrganization;
  final String? organizationName;
  final String? organizationRegNumber;
  final String? organizationAddress;
  final String? organizationBankAccount;
  final String? organizationBankName;
  final String? organizationLogoUrl;
  final String? organizationDocumentUrl;
  
  // Organization members
  final List<VerificationMember> members;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;

  UnifiedVerification({
    this.id,
    this.userId,
    this.status = 'pending',
    this.fullName,
    this.dateOfBirth,
    this.nationalId,
    this.address,
    this.phone,
    this.email,
    this.selfieUrl,
    this.idDocumentUrl,
    this.bankAccount,
    this.bankName,
    this.isOrganization = false,
    this.organizationName,
    this.organizationRegNumber,
    this.organizationAddress,
    this.organizationBankAccount,
    this.organizationBankName,
    this.organizationLogoUrl,
    this.organizationDocumentUrl,
    this.members = const [],
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'status': status,
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
      'national_id': nationalId,
      'address': address,
      'phone': phone,
      'email': email,
      'selfie_url': selfieUrl,
      'id_document_url': idDocumentUrl,
      'bank_account': bankAccount,
      'bank_name': bankName,
      'is_organization': isOrganization,
      'organization_name': organizationName,
      'organization_reg_number': organizationRegNumber,
      'organization_address': organizationAddress,
      'organization_bank_account': organizationBankAccount,
      'organization_bank_name': organizationBankName,
      'organization_logo_url': organizationLogoUrl,
      'organization_document_url': organizationDocumentUrl,
      // Don't include members in the main table data
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static UnifiedVerification fromMap(Map<String, dynamic> map) {
    // Members are handled separately and should not be part of the map
    List<VerificationMember> members = [];
    
    return UnifiedVerification(
      id: map['id'],
      userId: map['user_id'],
      status: map['status'] ?? 'pending',
      fullName: map['full_name'],
      dateOfBirth: map['date_of_birth'],
      nationalId: map['national_id'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      selfieUrl: map['selfie_url'],
      idDocumentUrl: map['id_document_url'],
      bankAccount: map['bank_account'],
      bankName: map['bank_name'],
      isOrganization: map['is_organization'] ?? false,
      organizationName: map['organization_name'],
      organizationRegNumber: map['organization_reg_number'],
      organizationAddress: map['organization_address'],
      organizationBankAccount: map['organization_bank_account'],
      organizationBankName: map['organization_bank_name'],
      organizationLogoUrl: map['organization_logo_url'],
      organizationDocumentUrl: map['organization_document_url'],
      members: members,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  UnifiedVerification copyWith({
    String? id,
    String? userId,
    String? status,
    String? fullName,
    String? dateOfBirth,
    String? nationalId,
    String? address,
    String? phone,
    String? email,
    String? selfieUrl,
    String? idDocumentUrl,
    String? bankAccount,
    String? bankName,
    bool? isOrganization,
    String? organizationName,
    String? organizationRegNumber,
    String? organizationAddress,
    String? organizationBankAccount,
    String? organizationBankName,
    String? organizationLogoUrl,
    String? organizationDocumentUrl,
    List<VerificationMember>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnifiedVerification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationalId: nationalId ?? this.nationalId,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      bankAccount: bankAccount ?? this.bankAccount,
      bankName: bankName ?? this.bankName,
      isOrganization: isOrganization ?? this.isOrganization,
      organizationName: organizationName ?? this.organizationName,
      organizationRegNumber: organizationRegNumber ?? this.organizationRegNumber,
      organizationAddress: organizationAddress ?? this.organizationAddress,
      organizationBankAccount: organizationBankAccount ?? this.organizationBankAccount,
      organizationBankName: organizationBankName ?? this.organizationBankName,
      organizationLogoUrl: organizationLogoUrl ?? this.organizationLogoUrl,
      organizationDocumentUrl: organizationDocumentUrl ?? this.organizationDocumentUrl,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  String toString() {
    return 'UnifiedVerification{id: $id, userId: $userId, status: $status, fullName: $fullName, isOrganization: $isOrganization}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnifiedVerification &&
      other.id == id &&
      other.userId == userId &&
      other.status == status;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ status.hashCode;
}
