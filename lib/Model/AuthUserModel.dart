class AuthUserModel {
  final String id;
  final String email;
  final String? userName;
  final String? phone;
  final String? avatar;
  final String? role;
  final bool? isVerified;
  final Map<String, dynamic>? address;

  AuthUserModel({
    required this.id,
    required this.email,
    this.userName,
    this.phone,
    this.avatar,
    this.role,
    this.isVerified,
    this.address,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      userName: json['userName']?.toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      role: json['role']?.toString(),
      isVerified: json['isVerified'] is bool ? json['isVerified'] as bool : null,
      address: json['address'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['address'] as Map) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'userName': userName,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'isVerified': isVerified,
      'address': address,
    };
  }
}
