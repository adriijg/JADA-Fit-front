class UserProfile {
  final String id;
  final String username;
  final String? bio;
  final String? profilePictureUrl;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final bool shareProgress;

  UserProfile({
    required this.id,
    required this.username,
    this.bio,
    this.profilePictureUrl,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    required this.shareProgress,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      bio: json['bio'],
      profilePictureUrl: json['profilePictureUrl'],
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
      shareProgress: json['shareProgress'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isFollowing': isFollowing,
      'shareProgress': shareProgress,
    };
  }
}
