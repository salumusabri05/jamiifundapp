class UserProfile {
  final String id;
  final DateTime? updatedAt;
  final String? username;
  final String fullName;
  final String? avatarUrl;
  final String? website;
  final String? phone;
  final String? address;
  final String? city;
  final String? region;
  final String? postalCode;
  final bool? isOrganization;
  final String? organizationName;
  final String? organizationRegNumber;
  final String? organizationType;
  final String? organizationDescription;
  final String? bio;
  final String? email;
  final String? location;
  final bool? isVerified;
  final String? idUrl;
  
  UserProfile({
    required this.id,
    this.updatedAt,
    this.username,
    required this.fullName,
    this.avatarUrl,
    this.website,
    this.phone,
    this.address,
    this.city,
    this.region,
    this.postalCode,
    this.isOrganization = false,
    this.organizationName,
    this.organizationRegNumber,
    this.organizationType,
    this.organizationDescription,
    this.bio,
    this.email,
    this.location,
    this.isVerified = false,
    this.idUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      username: json['username'],
      fullName: json['full_name'] as String? ?? 'User',
      avatarUrl: json['avatar_url'],
      website: json['website'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      region: json['region'],
      postalCode: json['postal_code'],
      isOrganization: json['is_organization'] ?? false,
      organizationName: json['organization_name'],
      organizationRegNumber: json['organization_reg_number'],
      organizationType: json['organization_type'],
      organizationDescription: json['organization_description'],
      bio: json['bio'],
      email: json['email'],
      location: json['location'],
      isVerified: json['is_verified'] ?? false,
      idUrl: json['id_url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    
    data['id'] = id; // id is required, not nullable
    if (updatedAt != null) data['updated_at'] = updatedAt!.toIso8601String();
    if (username != null) data['username'] = username;
    data['full_name'] = fullName; // fullName is required, not nullable
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (website != null) data['website'] = website;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (city != null) data['city'] = city;
    if (region != null) data['region'] = region;
    if (postalCode != null) data['postal_code'] = postalCode;
    data['is_organization'] = isOrganization ?? false;
    if (organizationName != null) data['organization_name'] = organizationName;
    if (organizationRegNumber != null) data['organization_reg_number'] = organizationRegNumber;
    if (organizationType != null) data['organization_type'] = organizationType;
    if (organizationDescription != null) data['organization_description'] = organizationDescription;
    if (bio != null) data['bio'] = bio;
    if (email != null) data['email'] = email;
    if (location != null) data['location'] = location;
    data['is_verified'] = isVerified ?? false;
    if (idUrl != null) data['id_url'] = idUrl;
    
    return data;
  }

  UserProfile copyWith({
    String? id,
    DateTime? updatedAt,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? website,
    String? phone,
    String? address,
    String? city,
    String? region,
    String? postalCode,
    bool? isOrganization,
    String? organizationName,
    String? organizationRegNumber,
    String? organizationType,
    String? organizationDescription,
    String? bio,
    String? email,
    String? location,
    bool? isVerified,
    String? idUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      isOrganization: isOrganization ?? this.isOrganization,
      organizationName: organizationName ?? this.organizationName,
      organizationRegNumber: organizationRegNumber ?? this.organizationRegNumber,
      organizationType: organizationType ?? this.organizationType,
      organizationDescription: organizationDescription ?? this.organizationDescription,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      idUrl: idUrl ?? this.idUrl,
    );
  }
}
