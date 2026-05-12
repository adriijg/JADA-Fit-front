class UserAccountModel {
  const UserAccountModel({
    required this.id,
    required this.username,
    required this.email,
    required this.onboardingCompleted,
    this.bio,
    this.profilePictureUrl,
    this.createdAt,
    this.shareProgress = true,
  });

  final String id;
  final String username;
  final String email;
  final bool onboardingCompleted;
  final String? bio;
  final String? profilePictureUrl;
  final DateTime? createdAt;
  final bool shareProgress;

  factory UserAccountModel.fromJson(Map<String, dynamic> json) {
    return UserAccountModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: _toDateTimeOrNull(json['createdAt']),
      shareProgress: json['shareProgress'] as bool? ?? true,
    );
  }

  static DateTime? _toDateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}