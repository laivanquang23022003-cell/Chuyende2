import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.email,
    required super.username,
    super.avatarUrl,
    required super.role,
    required super.pointBalance,
    required super.isPremium,
    super.premiumUntil,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'user',
      pointBalance: json['point_balance'] ?? 0,
      isPremium: json['is_premium'] ?? false,
      premiumUntil: json['premium_until'] != null 
          ? DateTime.parse(json['premium_until']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar_url': avatarUrl,
      'role': role,
      'point_balance': pointBalance,
      'is_premium': isPremium,
      'premium_until': premiumUntil?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
