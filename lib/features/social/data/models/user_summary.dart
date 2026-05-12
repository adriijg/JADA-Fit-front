class UserSummary {
  final String id;
  final String username;
  final String? profilePictureUrl;

  UserSummary({
    required this.id,
    required this.username,
    this.profilePictureUrl,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'],
      username: json['username'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
