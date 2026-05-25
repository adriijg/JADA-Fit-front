import 'user_summary.dart';

class PostComment {
  final String id;
  final UserSummary author;
  final String content;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'],
      author: UserSummary.fromJson(json['author']),
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
