import 'package:flutter/material.dart';
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
class _AiScreenState extends State<AiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AiProvider _aiProvider;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _aiProvider = context.read<AiProvider>();
    _aiProvider.setActive(true);
    _lastMessageCount = _aiProvider.messages.length;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void deactivate() {
    _aiProvider.setActive(false);
    super.deactivate();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiProvider>();
    final messages = aiProvider.messages;
    final isLoading = aiProvider.isLoading;

    if (messages.length > _lastMessageCount) {
      _lastMessageCount = messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyState()
              : _buildMessagesList(messages, isLoading),
        ),
        _buildInputBar(isLoading),
      ],
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.4),
            width: 0.7,
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Asistente IA',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Pregúntame sobre rutinas, nutrición o cualquier duda fitness.',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildMessagesList(List<ChatMessageModel> messages, bool isLoading) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Pensando...',
                  style: TextStyle(color: AppColors.textMain, fontSize: 13),
                ),
              ],
            ),
          );
        }
        final message = messages[index];
        final isUser = message.role == ChatMessageRole.user;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) _buildAvatar(),
              if (!isUser) const SizedBox(width: 10),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                            color: AppColors.divider.withOpacity(0.3),
                            width: 0.7,
                          ),
                  ),
                  child: isUser
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
                                color: AppColors.divider.withOpacity(0.3),
                              ),
                            ),
                            blockquoteDecoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: AppColors.primary.withOpacity(0.5),
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
                ),
              ),
              if (isUser) const SizedBox(width: 10),
              if (isUser) _buildAvatar(isUser: true),
            ],
          ),
        );
      },
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
  Widget _buildInputBar(bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.inputBorder.withOpacity(0.38),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  cursorColor: AppColors.primary,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu mensaje...',
                    hintStyle: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
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
      ),
    );
  }
}