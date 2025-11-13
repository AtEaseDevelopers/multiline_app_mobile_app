class User {
  final int id;
  final int? customId; // Some APIs return custom_id for driver login via ID
  final String name;
  final String?
  phone; // Nullable because API may return null when logging with ID
  final String? email; // Nullable when user logs in with ID/phone only
  final int? groupId; // Nullable for supervisors
  final String? avatar;
  final String? emailVerifiedAt;
  final String userType; // 'driver' or 'supervisor'
  final int isActive;
  final String? visiblePassword;
  final String? licenseExpiry;
  final String? medicalExpiry;
  final String? licenseExpiryRaw; // Keep raw date if needed for parsing later
  final String? medicalExpiryRaw;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    this.customId,
    required this.name,
    this.phone,
    this.email,
    this.groupId,
    this.avatar,
    this.emailVerifiedAt,
    required this.userType,
    required this.isActive,
    this.visiblePassword,
    this.licenseExpiry,
    this.medicalExpiry,
    this.licenseExpiryRaw,
    this.medicalExpiryRaw,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Defensive parsing: some backends send numbers as strings, and nulls for optional contact fields
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    int? parseNullableInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? parseNullableString(dynamic v) {
      if (v == null) return null;
      if (v is String) return v.isEmpty ? null : v;
      return v.toString();
    }

    return User(
      id: parseInt(json['id']),
      customId: parseNullableInt(json['custom_id']),
      name: (json['name'] ?? '').toString(),
      phone: parseNullableString(json['phone']),
      email: parseNullableString(json['email']),
      groupId: parseNullableInt(json['group_id']),
      avatar: parseNullableString(json['avatar']),
      emailVerifiedAt: parseNullableString(json['email_verified_at']),
      userType: (json['user_type'] ?? '').toString(),
      isActive: parseInt(json['is_active']),
      visiblePassword: parseNullableString(json['visible_password']),
      licenseExpiry: parseNullableString(json['license_expiry']),
      medicalExpiry: parseNullableString(json['medical_expiry']),
      licenseExpiryRaw: parseNullableString(json['license_expiry']),
      medicalExpiryRaw: parseNullableString(json['medical_expiry']),
      createdAt: parseNullableString(json['created_at']),
      updatedAt: parseNullableString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'custom_id': customId,
      'name': name,
      'phone': phone,
      'email': email,
      'group_id': groupId,
      'avatar': avatar,
      'email_verified_at': emailVerifiedAt,
      'user_type': userType,
      'is_active': isActive,
      'visible_password': visiblePassword,
      'license_expiry': licenseExpiry,
      'medical_expiry': medicalExpiry,
      'license_expiry_raw': licenseExpiryRaw,
      'medical_expiry_raw': medicalExpiryRaw,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isDriver => userType == 'driver';
  bool get isSupervisor => userType == 'supervisor';
  bool get isActiveUser => isActive == 1;

  /// Provide a stable identifier for display or storage if email is missing
  String get preferredIdentifier =>
      email ?? phone ?? (customId?.toString()) ?? id.toString();
}

class LoginResponse {
  final String accessToken;
  final String expiresIn;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'expires_in': expiresIn,
      'user': user.toJson(),
    };
  }
}
