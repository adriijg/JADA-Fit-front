import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/post.dart';
import '../../data/models/post_comment.dart';
import '../../data/services/post_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final String currentUserId;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<PostComment> _comments = [];
  bool _isLoadingComments = true;
  bool _isSending = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final comments = await _postService.getComments(widget.post.id);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingComments = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar comentarios: $e')),
        );
      }
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      final comment = await _postService.addComment(widget.post.id, text);
      if (mounted) {
        setState(() {
          _comments.add(comment);
          _isSending = false;
        });
        _commentController.clear();
        Future.delayed(Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar comentario: $e')),
        );
      }
    }
  }

  Future<void> _deletePost() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(l10n.socialDeletePost),
        content: Text(l10n.socialDeletePostConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.socialDeletePost,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await _postService.deletePost(widget.post.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final post = widget.post;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.socialPostDetail,
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        actions: [
          if (post.author.id == widget.currentUserId && !_isDeleting)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: context.colors.textMain),
              onSelected: (value) {
                if (value == 'delete') _deletePost();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(l10n.socialDeletePost, style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          if (_isDeleting)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              children: [
                // Post image
                ClipRRect(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Builder(
                      builder: (context) {
                        Widget errorPlaceholder() {
                          return Container(
                            color: context.colors.inputBackground,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: context.colors.secondary,
                                size: 48,
                              ),
                            ),
                          );
                        }

                        Widget loadingPlaceholder(
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: context.colors.inputBackground,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: context.colors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        final imageUrl = ImageUrlResolver.resolve(post.imageUrl);
                        return imageUrl.startsWith('http')
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    errorPlaceholder(),
                                loadingBuilder: loadingPlaceholder,
                              )
                            : Image.file(
                                File(imageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    errorPlaceholder(),
                              );
                      },
                    ),
                  ),
                ),

                // Author + caption
                Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: context.colors.primary.withOpacity(0.2),
                            backgroundImage: post.author.profilePictureUrl != null
                                ? NetworkImage(
                                    ImageUrlResolver.resolve(
                                      post.author.profilePictureUrl!,
                                    ),
                                  )
                                : null,
                            child: post.author.profilePictureUrl == null
                                ? Text(
                                    post.author.username[0].toUpperCase(),
                                    style: TextStyle(
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(width: 10),
                          Text(
                            post.author.username,
                            style: TextStyle(
                              color: context.colors.textMain,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Text(
                            _timeAgo(post.createdAt),
                            style: TextStyle(
                              color: context.colors.secondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (post.caption != null && post.caption!.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Text(
                          post.caption!,
                          style: TextStyle(
                            color: context.colors.textMain,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            post.likedByMe
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: post.likedByMe
                                ? Colors.redAccent
                                : context.colors.secondary,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${post.likesCount}',
                            style: TextStyle(
                              color: context.colors.secondary,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: context.colors.secondary,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${post.commentsCount}',
                            style: TextStyle(
                              color: context.colors.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: context.colors.divider.withOpacity(0.3)),

                // Comments section header
                Padding(
                  padding: EdgeInsets.fromLTRB(14, 14, 14, 8),
                  child: Text(
                    l10n.socialComments,
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),

                // Comments list
                if (_isLoadingComments)
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: context.colors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else if (_comments.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        l10n.socialNoCommentsYet,
                        style: TextStyle(
                          color: context.colors.secondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  ..._comments.map((comment) => _buildCommentTile(comment)),
              ],
            ),
          ),

          // Comment input bar
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(
                top: BorderSide(
                  color: context.colors.divider.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(12, 8, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.inputBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocus,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendComment(),
                      decoration: InputDecoration(
                        hintText: l10n.socialAddCommentHint,
                        hintStyle: TextStyle(
                          color: context.colors.secondary.withOpacity(0.6),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                InkResponse(
                  onTap: _isSending ? null : _sendComment,
                  radius: 20,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _isSending
                        ? Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(PostComment comment) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: context.colors.primary.withOpacity(0.15),
            backgroundImage: comment.author.profilePictureUrl != null
                ? NetworkImage(
                    ImageUrlResolver.resolve(comment.author.profilePictureUrl!),
                  )
                : null,
            child: comment.author.profilePictureUrl == null
                ? Text(
                    comment.author.username[0].toUpperCase(),
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author.username,
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: TextStyle(
                        color: context.colors.secondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  comment.content,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
