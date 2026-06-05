import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/services/ai_service.dart';

class ChatSession {
  final String id;
  final String title;
  final List<ChatMessageModel> messages;
  final DateTime createdAt;

  const ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
  });

  ChatSession copyWith({List<ChatMessageModel>? messages, String? title}) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toMap()).toList(),
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory ChatSession.fromMap(Map<String, dynamic> map) => ChatSession(
    id: map['id'] as String,
    title: map['title'] as String? ?? 'Chat',
    messages: (map['messages'] as List? ?? [])
        .map((m) => ChatMessageModel.fromMap(m as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
  );
}

class AiProvider extends ChangeNotifier {
  final AiService _aiService = AiService();
  final NotificationService _notificationService = NotificationService.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _storageKey = 'ai_chat_sessions';
  static const int maxSessions = 5;

  List<ChatSession> _sessions = [];
  int _currentSessionIndex = -1;
  bool _isLoading = false;
  bool _isActive = false;

  List<String> _initialSuggestions = [];
  List<String> _followUpSuggestions = [];
  String _errorMessage = '';
  String? _localeCode;

  List<String> _suggestedQuestions = [];

  List<ChatMessageModel> get messages => _currentSessionIndex >= 0
      ? List.unmodifiable(_sessions[_currentSessionIndex].messages)
      : [];
  bool get isLoading => _isLoading;
  List<String> get suggestedQuestions => List.unmodifiable(_suggestedQuestions);
  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  int get currentSessionIndex => _currentSessionIndex;
  bool get canCreateNewSession => _sessions.length < maxSessions;
  String? get currentSessionTitle => _currentSessionIndex >= 0
      ? _sessions[_currentSessionIndex].title
      : null;

  void updateLocalization(AppLocalizations l10n) {
    if (_localeCode == l10n.localeName && _initialSuggestions.isNotEmpty) return;

    final previousInitial = List<String>.from(_initialSuggestions);
    final wasShowingInitialSuggestions = _suggestedQuestions.isNotEmpty &&
        listEquals(_suggestedQuestions, previousInitial);

    _localeCode = l10n.localeName;
    _initialSuggestions = [
      l10n.aiSuggestionMacros,
      l10n.aiSuggestionDinner,
      l10n.aiSuggestionAnalyze,
      l10n.aiSuggestionAdvice,
    ];
    _followUpSuggestions = [
      l10n.aiSuggestionDeepDive,
      l10n.aiWhatElse,
      l10n.aiSuggestionWorkout,
      l10n.aiRecoveryTips,
    ];
    _errorMessage = l10n.aiErrorMessage;

    var shouldNotify = false;
    if (_suggestedQuestions.isEmpty || wasShowingInitialSuggestions) {
      _suggestedQuestions = List.of(_initialSuggestions);
      shouldNotify = true;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<void> loadSessions() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _sessions = list
            .map((s) => ChatSession.fromMap(s as Map<String, dynamic>))
            .toList();
        if (_sessions.isNotEmpty) _currentSessionIndex = _sessions.length - 1;
      }
    } catch (_) {}
    if (_sessions.isEmpty) _newSession();
    notifyListeners();
  }

  void _saveSessions() {
    try {
      final raw = jsonEncode(_sessions.map((s) => s.toMap()).toList());
      _storage.write(key: _storageKey, value: raw);
    } catch (_) {}
  }

  bool _newSession() {
    if (!canCreateNewSession) return false;
    _sessions.add(ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Chat ${_sessions.length + 1}',
      messages: [],
      createdAt: DateTime.now(),
    ));
    _currentSessionIndex = _sessions.length - 1;
    return true;
  }

  void switchToSession(int index) {
    if (index < 0 || index >= _sessions.length) return;
    _currentSessionIndex = index;
    _suggestedQuestions = List.of(_initialSuggestions);
    notifyListeners();
  }

  void deleteSession(int index) {
    if (index < 0 || index >= _sessions.length) return;
    _sessions.removeAt(index);
    if (_sessions.isEmpty) {
      _newSession();
    } else if (_currentSessionIndex >= _sessions.length) {
      _currentSessionIndex = _sessions.length - 1;
    } else if (index < _currentSessionIndex) {
      _currentSessionIndex--;
    }
    _saveSessions();
    notifyListeners();
  }

  bool newChat() {
    final created = _newSession();
    if (!created) return false;
    _suggestedQuestions = List.of(_initialSuggestions);
    _saveSessions();
    notifyListeners();
    return true;
  }

  void setActive(bool value) {
    _isActive = value;
  }

  void useSuggestion(String text) {
    sendMessage(text);
  }

  Future<void> sendMessage(String text) async {
    if (_currentSessionIndex < 0) _newSession();

    final session = _sessions[_currentSessionIndex];
    session.messages.add(ChatMessageModel(
      role: ChatMessageRole.user,
      text: text,
      timestamp: DateTime.now(),
    ));
    if (session.messages.length == 1) {
      _sessions[_currentSessionIndex] = session.copyWith(
        title: text.length > 40 ? '${text.substring(0, 40)}...' : text,
      );
    }
    _isLoading = true;
    _suggestedQuestions = [];
    notifyListeners();

    try {
      final history = session.messages
          .where((m) => m != session.messages.last)
          .toList();
      final response = await _aiService.chat(text, history);
      session.messages.add(ChatMessageModel(
        role: ChatMessageRole.ai,
        text: response,
        timestamp: DateTime.now(),
      ));
      _generateSuggestions(response);
      if (!_isActive) await _tryNotify();
    } catch (e) {
      session.messages.add(ChatMessageModel(
        role: ChatMessageRole.ai,
        text: _errorMessage.isNotEmpty ? _errorMessage : 'Error',
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      _saveSessions();
      notifyListeners();
    }
  }

  void _generateSuggestions(String response) {
    _suggestedQuestions = _followUpSuggestions.isNotEmpty
        ? List.of(_followUpSuggestions)
        : [];
  }

  Future<void> _tryNotify() async {
    try {
      await _notificationService.showResponseReady();
    } catch (_) {}
  }

  void clearMessages() {
    newChat();
  }
}
