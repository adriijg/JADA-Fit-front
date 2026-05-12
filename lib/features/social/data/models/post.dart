import 'user_summary.dart';

class Post {
  final String id;
  final UserSummary author;
  final String imageUrl;
  final String? caption;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.author,
    required this.imageUrl,
    this.caption,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      author: UserSummary.fromJson(json['author']),
      imageUrl: json['imageUrl'] ?? '',
      caption: json['caption'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
