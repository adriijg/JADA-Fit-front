import 'user_summary.dart';

class Post {
  final String id;
  final UserSummary author;
  final String imageUrl;
  final String? caption;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool likedByMe;

  Post({
    required this.id,
    required this.author,
    required this.imageUrl,
    this.caption,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.likedByMe = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      author: UserSummary.fromJson(json['author']),
      imageUrl: json['imageUrl'] ?? '',
      caption: json['caption'],
      createdAt: DateTime.parse(json['createdAt']),
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      likedByMe: json['likedByMe'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'likedByMe': likedByMe,
    };
  }

  Post copyWith({
    int? likesCount,
    int? commentsCount,
    bool? likedByMe,
  }) {
    return Post(
      id: id,
      author: author,
      imageUrl: imageUrl,
      caption: caption,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }
}
