class ChatMessageModel {
  const ChatMessageModel({
    required this.role,
    required this.text,
    this.timestamp,
  });

  final ChatMessageRole role;
  final String text;
  final DateTime? timestamp;
}

enum ChatMessageRole { user, ai }
