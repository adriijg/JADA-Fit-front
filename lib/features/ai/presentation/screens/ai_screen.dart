import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/chat_message_model.dart';
import '../providers/ai_provider.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  int _lastMessageCount = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final aiProvider = context.read<AiProvider>();
    aiProvider.setActive(true);
    _lastMessageCount = aiProvider.messages.length;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void deactivate() {
    context.read<AiProvider>().setActive(false);
    super.deactivate();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    context.read<AiProvider>().sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copiado al portapapeles'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ChatHistorySheet(
        onSelect: (index) {
          context.read<AiProvider>().switchToSession(index);
          Navigator.pop(context);
        },
        onDelete: (index) {
          context.read<AiProvider>().deleteSession(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiProvider>();
    final messages = aiProvider.messages;
    final isLoading = aiProvider.isLoading;
    final suggestions = aiProvider.suggestedQuestions;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (messages.length > _lastMessageCount) {
      _lastMessageCount = messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Column(
        children: [
          _buildHeader(aiProvider),
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(suggestions)
                : _buildMessagesList(messages, isLoading, suggestions),
          ),
          _buildInputBar(isLoading, bottomInset),
        ],
      ),
    );
  }

  Widget _buildHeader(AiProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              aiProvider.currentSessionTitle ?? 'Asistente IA',
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _HeaderButton(
            icon: Icons.history_rounded,
            onTap: _showHistory,
          ),
          const SizedBox(width: 6),
          _HeaderButton(
            icon: Icons.add_rounded,
            onTap: () => aiProvider.newChat(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(List<String> suggestions) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 36,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Asistente IA',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Pregúntame sobre rutinas, nutrición o cualquier duda fitness.',
            style: TextStyle(
              color: AppColors.textMain.withValues(alpha: 0.6),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 28),
        ...suggestions.map((s) => _buildSuggestionChip(s)),
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.read<AiProvider>().useSuggestion(text),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.3),
                width: 0.7,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(
    List<ChatMessageModel> messages,
    bool isLoading,
    List<String> suggestions,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      itemCount: messages.length + (isLoading ? 1 : 0) + (suggestions.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isLoading) {
          return _buildTypingIndicator();
        }
        if (index >= messages.length) {
          return _buildSuggestedQuestions(suggestions);
        }
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.3),
                  width: 0.7,
                ),
              ),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      return Padding(
                        padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: _pulseAnimation.value - (i * 0.15).clamp(0.0, 1.0)),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions(List<String> suggestions) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions.map((s) {
          return ActionChip(
            label: Text(
              s,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 0.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => context.read<AiProvider>().useSuggestion(s),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    final isUser = message.role == ChatMessageRole.user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(),
          if (!isUser) const SizedBox(width: 10),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        width: 0.7,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isUser
                      ? Text(
                          message.text,
                          style: const TextStyle(
                            color: AppColors.background,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        )
                      : MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: AppColors.textMain,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            strong: const TextStyle(
                              color: AppColors.textMain,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            em: const TextStyle(
                              color: AppColors.textMain,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                            code: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 13,
                              backgroundColor: Color(0x3300E5FF),
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.divider.withValues(alpha: 0.3),
                              ),
                            ),
                            blockquoteDecoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  width: 3,
                                ),
                              ),
                              color: AppColors.inputBackground,
                            ),
                            listBullet: const TextStyle(
                              color: AppColors.textMain,
                              fontSize: 14,
                            ),
                            h1: const TextStyle(
                              color: AppColors.textMain,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: const TextStyle(
                              color: AppColors.textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: const TextStyle(
                              color: AppColors.textMain,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  if (!isUser)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMessageAction(
                            icon: Icons.copy_rounded,
                            onTap: () => _copyMessage(message.text),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
          if (isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildMessageAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 14,
            color: AppColors.textMain.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar({bool isUser = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? AppColors.secondary : AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.auto_awesome,
        size: 18,
        color: AppColors.background,
      ),
    );
  }

  Widget _buildInputBar(bool isLoading, double bottomInset) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 8, 0, bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.inputBorder.withValues(alpha: 0.38),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                cursorColor: AppColors.primary,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  hintStyle: TextStyle(
                    color: AppColors.textMain.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: isLoading ? AppColors.divider : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send_rounded),
              color: AppColors.background,
              iconSize: 20,
              splashRadius: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.3),
              width: 0.7,
            ),
          ),
          child: Icon(icon, size: 20, color: AppColors.textMain),
        ),
      ),
    );
  }
}

class _ChatHistorySheet extends StatelessWidget {
  final void Function(int index) onSelect;
  final void Function(int index) onDelete;

  const _ChatHistorySheet({
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiProvider>();
    final sessions = aiProvider.sessions;
    final currentIndex = aiProvider.currentSessionIndex;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'HISTORIAL',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: sessions.isEmpty
                ? const Center(
                    child: Text(
                      'No hay conversaciones guardadas',
                      style: TextStyle(color: AppColors.textMain),
                    ),
                  )
                : ListView.separated(
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: AppColors.divider,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final isCurrent = index == currentIndex;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        leading: Icon(
                          Icons.chat_rounded,
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.textMain.withValues(alpha: 0.5),
                          size: 22,
                        ),
                        title: Text(
                          session.title,
                          style: TextStyle(
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.textMain,
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${session.messages.length} mensajes',
                          style: TextStyle(
                            color: AppColors.textMain.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppColors.textMain.withValues(alpha: 0.4),
                          ),
                          onPressed: () => onDelete(index),
                        ),
                        selected: isCurrent,
                        onTap: isCurrent ? null : () => onSelect(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
