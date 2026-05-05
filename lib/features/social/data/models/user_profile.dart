class UserProfile {
  final String id;
  final String username;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final bool shareProgress;

  UserProfile({
    required this.id,
    required this.username,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    required this.shareProgress,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
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
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isFollowing': isFollowing,
      'shareProgress': shareProgress,
    };
  }
}
