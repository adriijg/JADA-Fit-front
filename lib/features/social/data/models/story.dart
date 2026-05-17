import 'user_summary.dart';

class Story {
  final String id;
  final UserSummary author;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime expiresAt;

  Story({
    required this.id,
    required this.author,
    required this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      author: UserSummary.fromJson(json['author']),
      imageUrl: json['imageUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}
