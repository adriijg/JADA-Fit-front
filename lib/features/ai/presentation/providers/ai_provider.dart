import 'package:flutter/foundation.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/services/ai_service.dart';
class AiProvider extends ChangeNotifier {
  final AiService _aiService = AiService();
  final NotificationService _notificationService = NotificationService();
  final List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  bool _isActive = false;
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  void setActive(bool value) {
    _isActive = value;
  }
  Future<void> sendMessage(String text) async {
    _messages.add(ChatMessageModel(
      role: ChatMessageRole.user,
      text: text,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _aiService.chat(text);
      _messages.add(ChatMessageModel(
        role: ChatMessageRole.ai,
        text: response,
        timestamp: DateTime.now(),
      ));
      if (!_isActive) await _tryNotify();
    } catch (e) {
      _messages.add(ChatMessageModel(
        role: ChatMessageRole.ai,
        text: 'Lo siento, ocurrió un error.',
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> _tryNotify() async {
    try {
      await _notificationService.showResponseReady();
    } catch (_) {}
  }
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}