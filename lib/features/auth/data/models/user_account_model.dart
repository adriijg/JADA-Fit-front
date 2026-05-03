class UserAccountModel {
  const UserAccountModel({
    required this.id,
    required this.username,
    required this.email,
    required this.onboardingCompleted,
    this.createdAt,
  });

  final String id;
  final String username;
  final String email;
  final bool onboardingCompleted;
  final DateTime? createdAt;

  factory UserAccountModel.fromJson(Map<String, dynamic> json) {
    return UserAccountModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      createdAt: _toDateTimeOrNull(json['createdAt']),
    );
  }

  static DateTime? _toDateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}