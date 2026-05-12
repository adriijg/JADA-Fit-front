import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/post.dart';
import '../../data/models/story.dart';
import '../../data/services/post_service.dart';
import '../../data/services/story_service.dart';
import 'explore_screen.dart';
import 'my_social_profile_screen.dart';
import 'story_viewer_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  int _currentTab = 0;

  final List<Widget> _screens = const [
    _FeedTab(),
    ExploreScreen(),
    MySocialProfileScreen(),
  ];

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
            });
          },
        ),
        // Content
        Expanded(
          child: IndexedStack(
            index: _currentTab,
            children: _screens,
          ),
        ),
      ],
    );
  }
}

// ─── Top Navigation Bar ──────────────────────────────────────────────────────

class _SocialTopBar extends StatelessWidget {
  const _SocialTopBar({
    required this.currentTab,
    required this.onTabSelected,
  });

  final int currentTab;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _TabButton(
            icon: Icons.home_rounded,
            label: 'Inicio',
            isSelected: currentTab == 0,
            onTap: () => onTabSelected(0),
          ),
          _TabButton(
            icon: Icons.explore_rounded,
            label: 'Explorar',
            isSelected: currentTab == 1,
            onTap: () => onTabSelected(1),
          ),
          _TabButton(
            icon: Icons.person_rounded,
            label: 'Mi Perfil',
            isSelected: currentTab == 2,
            onTap: () => onTabSelected(2),
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.secondary,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.secondary,
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
  final StoryService _storyService = StoryService();

  List<Post> _posts = [];
  List<Story> _stories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return _ErrorView(
        message: _error!,
        onRetry: _loadFeed,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tu feed está vacío',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sigue a otros usuarios para ver sus\npublicaciones e historias aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondary,
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
      padding: const EdgeInsets.only(bottom: 24),
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
                    stories: _stories.where((s) => s.author.id == story.author.id).toList(),
                    authorName: story.author.username,
                  ),
                ),
              );
            },
          );
        }

        final postIndex = _stories.isNotEmpty ? index - 1 : index;
        final post = _posts[postIndex];
        return _PostCard(post: post);
      },
    );
  }
}

// ─── Stories Bar ─────────────────────────────────────────────────────────────

class _StoriesBar extends StatelessWidget {
  const _StoriesBar({
    required this.stories,
    required this.onStoryTap,
  });

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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: authorStories.length,
        itemBuilder: (context, index) {
          final story = authorStories.values.elementAt(index);
          return GestureDetector(
            onTap: () => onStoryTap(story),
            child: Container(
              width: 76,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundColor: AppColors.surface,
                        backgroundImage: story.author.profilePictureUrl != null
                            ? NetworkImage(story.author.profilePictureUrl!)
                            : null,
                        child: story.author.profilePictureUrl == null
                            ? Text(
                                story.author.username[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    story.author.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMain,
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
  const _PostCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundImage: post.author.profilePictureUrl != null
                      ? NetworkImage(post.author.profilePictureUrl!)
                      : null,
                  child: post.author.profilePictureUrl == null
                      ? Text(
                          post.author.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.username,
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _timeAgo(post.createdAt),
                        style: TextStyle(
                          color: AppColors.secondary.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),

          // Post image
          ClipRRect(
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.inputBackground,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.secondary,
                        size: 48,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.inputBackground,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Caption
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(14),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${post.author.username} ',
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: post.caption!,
                      style: const TextStyle(
                        color: AppColors.textMain,
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
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                _ActionIcon(icon: Icons.favorite_border_rounded),
                const SizedBox(width: 16),
                _ActionIcon(icon: Icons.chat_bubble_outline_rounded),
                const SizedBox(width: 16),
                _ActionIcon(icon: Icons.send_outlined),
                const Spacer(),
                _ActionIcon(icon: Icons.bookmark_border_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: AppColors.textMain.withValues(alpha: 0.8),
      size: 22,
    );
  }
}

// ─── Error View ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              label: const Text(
                'Reintentar',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
