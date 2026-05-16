class ChatMessageModel {
  const ChatMessageModel({
    required this.role,
    required this.text,
    this.timestamp,
  });

  final ChatMessageRole role;
  final String text;
  final DateTime? timestamp;

  Map<String, dynamic> toJson() => {
    'role': role == ChatMessageRole.user ? 'user' : 'assistant',
    'content': text,
  };

  Map<String, dynamic> toMap() => {
    'role': role == ChatMessageRole.user ? 'user' : 'assistant',
    'text': text,
    'timestamp': timestamp?.millisecondsSinceEpoch,
  };

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    final ts = map['timestamp'] as int?;
    return ChatMessageModel(
      role: map['role'] == 'user' ? ChatMessageRole.user : ChatMessageRole.ai,
      text: map['text'] as String? ?? '',
      timestamp: ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null,
    );
  }
}

enum ChatMessageRole { user, ai }
