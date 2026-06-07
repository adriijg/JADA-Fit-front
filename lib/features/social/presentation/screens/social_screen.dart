import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../data/models/post.dart';
import '../../data/models/story.dart';
import '../../data/models/challenge.dart';
import '../../data/models/user_summary.dart';
import '../../data/services/post_service.dart';
import '../../data/services/social_service.dart';
import '../../data/services/story_service.dart';
import '../../data/services/challenge_service.dart';
import 'explore_screen.dart';
import 'my_social_profile_screen.dart';
import 'post_detail_screen.dart';
import 'story_viewer_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  int _currentTab = 0;
  int _profileRefreshVersion = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top navigation bar (Instagram-style)
        _SocialTopBar(
          currentTab: _currentTab,
          onTabSelected: (index) {
            setState(() {
              _currentTab = index;
              if (index == 3) {
                _profileRefreshVersion++;
              }
            });
          },
        ),
        // Content
        Expanded(
          child: IndexedStack(
            index: _currentTab,
            children: [
              const _FeedTab(),
              ExploreScreen(),
              const _PiquesTab(),
              MySocialProfileScreen(refreshVersion: _profileRefreshVersion),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Top Navigation Bar ──────────────────────────────────────────────────────

class _SocialTopBar extends StatelessWidget {
  const _SocialTopBar({required this.currentTab, required this.onTabSelected});

  final int currentTab;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.divider.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _TabButton(
            icon: Icons.home_rounded,
            label: l10n.navigationHome,
            isSelected: currentTab == 0,
            onTap: () => onTabSelected(0),
          ),
          _TabButton(
            icon: Icons.explore_rounded,
            label: l10n.socialExplore,
            isSelected: currentTab == 1,
            onTap: () => onTabSelected(1),
          ),
          _TabButton(
            icon: Icons.emoji_events_outlined,
            label: l10n.socialChallenges,
            isSelected: currentTab == 2,
            onTap: () => onTabSelected(2),
          ),
          _TabButton(
            icon: Icons.person_rounded,
            label: l10n.socialMyProfile,
            isSelected: currentTab == 3,
            onTap: () => onTabSelected(3),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? context.colors.primary
                    : context.colors.secondary,
                size: 22,
              ),
              SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.secondary,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Feed Tab (Home) ─────────────────────────────────────────────────────────

class _FeedTab extends StatefulWidget {
  const _FeedTab();

  @override
  State<_FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<_FeedTab> {
  final PostService _postService = PostService();
  final SocialService _socialService = SocialService();
  final StoryService _storyService = StoryService();
  final AuthService _authService = AuthService();

  List<Post> _posts = [];
  List<Story> _stories = [];
  final Set<String> _likeRequests = {};
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() => _currentUserId = user.id);
      }
    } catch (_) {}
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _postService.getFeed(),
        _storyService.getFeedStories(),
      ]);

      if (mounted) {
        setState(() {
          _posts = results[0] as List<Post>;
          _stories = results[1] as List<Story>;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deletePost(Post post) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(
          l10n?.socialDeletePostConfirm ?? 'Delete this post?',
          style: TextStyle(color: context.colors.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              l10n!.nutritionCancel,
              style: TextStyle(color: context.colors.secondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n?.socialDeletePost ?? 'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _postService.deletePost(post.id);
      if (mounted) {
        setState(() => _posts.removeWhere((p) => p.id == post.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.socialDeletePostSuccess ?? 'Post deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.socialDeletePostError(e.toString()) ?? 'Error deleting post'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (_error != null) {
      return _ErrorView(message: _error!, onRetry: _loadFeed);
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      color: context.colors.primary,
      child: _posts.isEmpty && _stories.isEmpty
          ? _buildEmptyFeed()
          : _buildFeedContent(),
    );
  }

  Widget _buildEmptyFeed() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    color: context.colors.primary,
                    size: 36,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.socialFeedEmpty,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.socialFollowOthers,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.colors.secondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedContent() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 12, bottom: 24),
      itemCount: _posts.length + (_stories.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        // Stories bar at the top
        if (_stories.isNotEmpty && index == 0) {
          return _StoriesBar(
            stories: _stories,
            onStoryTap: (story) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryViewerScreen(
                    stories: _stories
                        .where((s) => s.author.id == story.author.id)
                        .toList(),
                    authorName: story.author.username,
                    currentUserId: _currentUserId,
                  ),
                ),
              );
            },
          );
        }

        final postIndex = _stories.isNotEmpty ? index - 1 : index;
        final post = _posts[postIndex];
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _PostCard(
            post: post,
            currentUserId: _currentUserId,
            isLikeBusy: _likeRequests.contains(post.id),
            onLike: () => _toggleLike(post),
            onComment: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(post: post, currentUserId: _currentUserId!),
                ),
              );
            },
            onSend: () => _showSendSheet(post),
            onDelete: () => _deletePost(post),
          ),
        );
      },
    );
  }

  Future<void> _toggleLike(Post post) async {
    if (_likeRequests.contains(post.id)) return;

    final wasLiked = post.likedByMe;
    final optimisticPost = post.copyWith(
      likedByMe: !wasLiked,
      likesCount: wasLiked
          ? (post.likesCount - 1).clamp(0, post.likesCount)
          : post.likesCount + 1,
    );

    setState(() {
      _likeRequests.add(post.id);
      _replacePost(optimisticPost);
    });

    try {
      if (wasLiked) {
        await _postService.unlikePost(post.id);
      } else {
        await _postService.likePost(post.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.socialLikeSuccess(post.author.username)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _replacePost(post));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.socialLikeError(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _likeRequests.remove(post.id));
      }
    }
  }

  void _replacePost(Post post) {
    final index = _posts.indexWhere((item) => item.id == post.id);
    if (index == -1) return;
    _posts[index] = post;
  }

  Future<void> _showSendSheet(Post post) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return FutureBuilder(
          future: _loadFollowingUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 220,
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBottomSheetHandle(),
                    SizedBox(height: 18),
                    Icon(Icons.error_outline, color: AppColors.error, size: 34),
                    SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.socialLoadFollowingError,
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }

            final users = snapshot.data ?? [];
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 12, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBottomSheetHandle(),
                    SizedBox(height: 18),
                    Text(
                      AppLocalizations.of(context)!.socialSendTo,
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 14),
                    if (users.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child:                           Text(
                            AppLocalizations.of(context)!.socialNoFollowing,
                            style: TextStyle(color: context.colors.secondary),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: users.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Material(
                              color: context.colors.inputBackground,
                              borderRadius: BorderRadius.circular(14),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: context.colors.primary
                                      .withOpacity(0.18),
                                  backgroundImage:
                                      user.profilePictureUrl != null
                                      ? NetworkImage(
                                          ImageUrlResolver.resolve(
                                            user.profilePictureUrl!,
                                          ),
                                        )
                                      : null,
                                  child: user.profilePictureUrl == null
                                      ? Text(
                                          user.username[0].toUpperCase(),
                                          style: TextStyle(
                                            color: context.colors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  user.username,
                                  style: TextStyle(
                                    color: context.colors.textMain,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.send_rounded,
                                  color: context.colors.primary,
                                  size: 20,
                                ),
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context)!.socialPostSent(user.username),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<UserSummary>> _loadFollowingUsers() async {
    final currentUser = await _authService.getCurrentUser();
    return _socialService.getFollowing(currentUser.id);
  }
}

// ─── Stories Bar ─────────────────────────────────────────────────────────────

class _StoriesBar extends StatelessWidget {
  const _StoriesBar({required this.stories, required this.onStoryTap});

  final List<Story> stories;
  final ValueChanged<Story> onStoryTap;

  @override
  Widget build(BuildContext context) {
    // Group stories by author
    final Map<String, Story> authorStories = {};
    for (final story in stories) {
      if (!authorStories.containsKey(story.author.id)) {
        authorStories[story.author.id] = story;
      }
    }

    return Container(
      height: 110,
      margin: EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemCount: authorStories.length,
        itemBuilder: (context, index) {
          final story = authorStories.values.elementAt(index);
          return GestureDetector(
            onTap: () => onStoryTap(story),
            child: Container(
              width: 76,
              margin: EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          context.colors.primary,
                          context.colors.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(2.5),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.background,
                      ),
                      padding: EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundImage: story.author.profilePictureUrl != null
                            ? NetworkImage(
                                ImageUrlResolver.resolve(
                                  story.author.profilePictureUrl!,
                                ),
                              )
                            : null,
                        child: story.author.profilePictureUrl == null
                            ? Text(
                                story.author.username[0].toUpperCase(),
                                style: TextStyle(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    story.author.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Post Card ───────────────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onSend,
    required this.onComment,
    required this.onDelete,
    required this.isLikeBusy,
  });

  final Post post;
  final String? currentUserId;
  final VoidCallback onLike;
  final VoidCallback onSend;
  final VoidCallback onComment;
  final VoidCallback onDelete;
  final bool isLikeBusy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      borderRadius: 20,
      borderColor: context.colors.divider.withOpacity(0.3),
      borderWidth: 0.5,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
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
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.username,
                        style: TextStyle(
                          color: context.colors.textMain,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _timeAgo(post.createdAt, l10n),
                        style: TextStyle(
                          color: context.colors.secondary.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.author.id == currentUserId)
                  InkResponse(
                    onTap: () => _showPostMenu(context),
                    radius: 18,
                    child: Icon(
                      Icons.more_horiz,
                      color: context.colors.secondary.withOpacity(0.5),
                      size: 20,
                    ),
                  )
                else
                  Icon(
                    Icons.more_horiz,
                    color: context.colors.secondary.withOpacity(0.5),
                    size: 20,
                  ),
              ],
            ),
          ),

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

          // Caption
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(14),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${post.author.username} ',
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: post.caption!,
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom actions bar
          Padding(
            padding: EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Row(
              children: [
                _ActionIcon(
                  icon: post.likedByMe
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: post.likedByMe
                      ? Colors.redAccent
                      : context.colors.textMain.withOpacity(0.8),
                  onTap: isLikeBusy ? null : onLike,
                ),
                if (post.likesCount > 0) ...[
                  SizedBox(width: 6),
                  Text(
                    '${post.likesCount}',
                    style: TextStyle(
                      color: context.colors.textMain.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                SizedBox(width: 16),
                _ActionIcon(
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: onComment,
                ),
                if (post.commentsCount > 0) ...[
                  SizedBox(width: 6),
                  Text(
                    '${post.commentsCount}',
                    style: TextStyle(
                      color: context.colors.textMain.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                SizedBox(width: 16),
                _ActionIcon(icon: Icons.send_outlined, onTap: onSend),
                Spacer(),
                _ActionIcon(icon: Icons.bookmark_border_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPostMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: context.colors.secondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: Text(
                    l10n.socialDeletePost,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return l10n.socialTimeAgoNow;
    if (diff.inMinutes < 60) return l10n.socialTimeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.socialTimeAgoHours(diff.inHours);
    if (diff.inDays < 7) return l10n.socialTimeAgoDays(diff.inDays);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, this.onTap, this.color});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: EdgeInsets.all(2),
        child: Icon(
          icon,
          color: color ?? context.colors.textMain.withOpacity(0.8),
          size: 22,
        ),
      ),
    );
  }
}

// ─── Error View ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 48),
            SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.secondary, fontSize: 14),
            ),
            SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, color: context.colors.primary),
              label: Text(
                AppLocalizations.of(context)!.nutritionRetry,
                style: TextStyle(color: context.colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Piques Tab ──────────────────────────────────────────────────────────────

class _PiquesTab extends StatefulWidget {
  const _PiquesTab();

  @override
  State<_PiquesTab> createState() => _PiquesTabState();
}

class _PiquesTabState extends State<_PiquesTab> {
  final ChallengeService _challengeService = ChallengeService();
  final AuthService _authService = AuthService();
  List<Challenge> _myChallenges = [];
  bool _isLoadingChallenges = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUserId = user.id;
        });
      }
    } catch (_) {}
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoadingChallenges = true;
    });

    try {
      final challenges = await _challengeService.getMyChallenges();
      if (mounted) {
        setState(() {
          _myChallenges = challenges;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.socialChallengeLoadError(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingChallenges = false;
        });
      }
    }
  }

  List<Challenge> get _activeChallenges =>
      _myChallenges.where((c) => !c.isExpired).toList();

  List<Challenge> get _expiredChallenges =>
      _myChallenges.where((c) => c.isExpired).toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoadingChallenges) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    final active = _activeChallenges;
    final expired = _expiredChallenges;

    if (active.isEmpty && expired.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: context.colors.secondary,
            ),
            SizedBox(height: 16),
            Text(
              l10n.socialNoActiveChallenges,
              style: TextStyle(
                color: context.colors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.socialChallengeFriends,
              style: TextStyle(color: context.colors.secondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showUpdateRecordDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.socialUpdateMyRecords),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      color: context.colors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 1 + active.length + (expired.isNotEmpty ? 1 + expired.length : 0),
        itemBuilder: (context, index) {
          // Header
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.socialYourChallenges,
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (expired.isNotEmpty)
                        TextButton.icon(
                          onPressed: _confirmDeleteExpired,
                          icon: Icon(Icons.delete_sweep_outlined, color: Colors.red, size: 18),
                          label: Text(
                            l10n.socialChallengeDeleteExpired,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      TextButton.icon(
                        onPressed: _showUpdateRecordDialog,
                        icon: Icon(Icons.add, color: context.colors.primary),
                        label: Text(
                          l10n.socialMyRecords,
                          style: TextStyle(color: context.colors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          int offset = 1;

          // Active challenges
          if (index - offset < active.length) {
            return _buildChallengeCard(active[index - offset], _currentUserId);
          }
          offset += active.length;

          // Expired section header + challenges
          if (expired.isNotEmpty) {
            if (index == offset) {
              return Padding(
                padding: EdgeInsets.only(top: 8, bottom: 12),
                child: _buildSectionHeader('${l10n.socialChallengeExpired} (${expired.length})'),
              );
            }
            offset++;
            return _buildChallengeCard(expired[index - offset], _currentUserId);
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: context.colors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(child: Divider(color: context.colors.divider.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildChallengeCard(Challenge challenge, String? currentUserId) {
    final l10n = AppLocalizations.of(context)!;
    final bool isChallenger = challenge.challenger.id == currentUserId;
    final bool isChallenged = challenge.challenged.id == currentUserId;
    final bool expired = challenge.isExpired;

    return Opacity(
      opacity: expired ? 0.55 : 1.0,
      child: Card(
        color: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: expired
              ? BorderSide(color: context.colors.divider.withOpacity(0.2))
              : BorderSide.none,
        ),
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAvatar(challenge.challenger.username),
                  SizedBox(width: 8),
                  Text('vs', style: TextStyle(color: context.colors.secondary, fontStyle: FontStyle.italic, fontSize: 12)),
                  SizedBox(width: 8),
                  _buildAvatar(challenge.challenged.username),
                  Spacer(),
                  _buildStatusBadge(challenge.status, expired),
                ],
              ),
              SizedBox(height: 14),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colors.primary.withOpacity(0.08),
                        context.colors.secondary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fitness_center, color: context.colors.primary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        challenge.exerciseName,
                        style: TextStyle(
                          color: context.colors.textMain,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeightInfo(challenge.challenger.username, challenge.challengerWeight),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: Colors.orange, size: 14),
                        SizedBox(width: 4),
                        Text('VS', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        SizedBox(width: 4),
                        Icon(Icons.bolt, color: Colors.orange, size: 14),
                      ],
                    ),
                  ),
                  _buildWeightInfo(challenge.challenged.username, challenge.challengedWeight),
                ],
              ),
              if (!expired && challenge.status != ChallengeStatus.FINISHED && challenge.status != ChallengeStatus.REJECTED) ...[
                SizedBox(height: 10),
                _buildExpirationInfo(challenge, l10n),
              ],
              if (expired) ...[
                SizedBox(height: 10),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: context.colors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_off_outlined, color: context.colors.secondary, size: 14),
                        SizedBox(width: 4),
                        Text(
                          l10n.socialChallengeExpired,
                          style: TextStyle(color: context.colors.secondary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (challenge.status == ChallengeStatus.PENDING && isChallenged && !expired) ...[
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rejectChallenge(challenge.id),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(l10n.socialReject, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptChallenge(challenge.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(l10n.socialAccept, style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
              if (challenge.status == ChallengeStatus.PENDING && isChallenger && !expired) ...[
                SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_empty, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Text(
                          l10n.socialChallengeAwaitingConfirmation,
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String username) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: context.colors.primary.withOpacity(0.1),
      child: Text(
        username[0].toUpperCase(),
        style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildExpirationInfo(Challenge challenge, AppLocalizations l10n) {
    final remaining = challenge.timeRemaining;
    if (remaining == null) return SizedBox.shrink();

    String timeText;
    Color timerColor;

    if (remaining.inDays > 0) {
      timeText = '${remaining.inDays}d ${remaining.inHours.remainder(24)}h';
      timerColor = context.colors.primary;
    } else if (remaining.inHours > 0) {
      timeText = '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m';
      timerColor = Colors.orange;
    } else if (remaining.inMinutes > 0) {
      timeText = '${remaining.inMinutes}m';
      timerColor = Colors.red;
    } else {
      timeText = '< 1m';
      timerColor = Colors.red;
    }

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: timerColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, color: timerColor, size: 14),
            SizedBox(width: 4),
            Text(
              l10n.socialChallengeExpiresIn(timeText),
              style: TextStyle(color: timerColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInfo(String username, double weight) {
    return Column(
      children: [
        Text(
          username,
          style: TextStyle(color: context.colors.secondary, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2),
        Text(
          '${weight.toStringAsFixed(1)} kg',
          style: TextStyle(color: context.colors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ChallengeStatus status, bool expired) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String text;

    if (expired) {
      color = context.colors.secondary;
      text = l10n.socialChallengeExpired;
    } else {
      switch (status) {
        case ChallengeStatus.PENDING:
          color = Colors.orange;
          text = l10n.socialChallengeStatusPending;
          break;
        case ChallengeStatus.ACCEPTED:
          color = Colors.green;
          text = l10n.socialChallengeStatusActive;
          break;
        case ChallengeStatus.REJECTED:
          color = Colors.red;
          text = l10n.socialChallengeStatusRejected;
          break;
        case ChallengeStatus.FINISHED:
          color = context.colors.primary;
          text = l10n.socialChallengeStatusFinished;
          break;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _acceptChallenge(String id) async {
    try {
      await _challengeService.acceptChallenge(id);
      _loadChallenges();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.socialErrorDetails(e.toString()))),
      );
    }
  }

  Future<void> _rejectChallenge(String id) async {
    try {
      await _challengeService.rejectChallenge(id);
      _loadChallenges();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.socialErrorDetails(e.toString()))),
      );
    }
  }

  Future<void> _confirmDeleteExpired() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(l10n.socialChallengeConfirmDeleteExpired, style: TextStyle(color: context.colors.textMain)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.nutritionCancel, style: TextStyle(color: context.colors.secondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.socialChallengeDeleteExpired, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _myChallenges.removeWhere((c) => c.isExpired);
      });
    }
  }

  void _showUpdateRecordDialog() {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController exerciseController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.socialUpdatePersonalRecord, style: TextStyle(color: context.colors.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: exerciseController,
              decoration: InputDecoration(
                labelText: l10n.socialExerciseHint,
                labelStyle: TextStyle(color: context.colors.secondary),
              ),
              style: TextStyle(color: context.colors.textMain),
            ),
            SizedBox(height: 16),
            TextField(
              controller: weightController,
              decoration: InputDecoration(
                labelText: l10n.socialWeightKg,
                labelStyle: TextStyle(color: context.colors.secondary),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: context.colors.textMain),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.nutritionCancel, style: TextStyle(color: context.colors.secondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final exercise = exerciseController.text;
              final weight = double.tryParse(weightController.text);
              if (exercise.isNotEmpty && weight != null) {
                try {
                  await _challengeService.updateRecord(exercise, weight);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadChallenges();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.socialRecordUpdated)),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.socialErrorDetails(e.toString()))),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
            child: Text(l10n.socialSave),
          ),
        ],
      ),
    );
  }
}
