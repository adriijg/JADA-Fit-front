import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/post.dart';
import '../../data/models/story.dart';
import '../../data/models/challenge.dart';
import '../../data/services/post_service.dart';
import '../../data/services/story_service.dart';
import '../../data/services/social_service.dart';
import '../../data/services/challenge_service.dart';
import 'explore_screen.dart';
import 'my_social_profile_screen.dart';
import 'story_viewer_screen.dart';
import 'user_profile_screen.dart';

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
    _PiquesTab(),
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
        color: AppColors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.3),
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
            icon: Icons.emoji_events_outlined,
            label: 'Piques',
            isSelected: currentTab == 2,
            onTap: () => onTabSelected(2),
          ),
          _TabButton(
            icon: Icons.person_rounded,
            label: 'Mi Perfil',
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.15)
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
                    color: AppColors.primary.withOpacity(0.1),
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
                          color: AppColors.primary.withOpacity(0.3),
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
    return AppCard(
      borderRadius: 20,
      borderColor: AppColors.divider.withOpacity(0.3),
      borderWidth: 0.5,
      padding: EdgeInsets.zero,
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
                  backgroundColor: AppColors.primary.withOpacity(0.2),
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
                          color: AppColors.secondary.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: AppColors.secondary.withOpacity(0.5),
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
                      color: AppColors.inputBackground,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.secondary,
                          size: 48,
                        ),
                      ),
                    );
                  }

                  Widget loadingPlaceholder(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
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
                  }

                  return post.imageUrl.startsWith('http')
                      ? Image.network(
                          post.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => errorPlaceholder(),
                          loadingBuilder: loadingPlaceholder,
                        )
                      : Image.file(
                          File(post.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => errorPlaceholder(),
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
      color: AppColors.textMain.withOpacity(0.8),
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

// ─── Piques Tab ──────────────────────────────────────────────────────────────

class _PiquesTab extends StatefulWidget {
  const _PiquesTab();

  @override
  State<_PiquesTab> createState() => _PiquesTabState();
}

class _PiquesTabState extends State<_PiquesTab> {
  final ChallengeService _challengeService = ChallengeService();
  List<Challenge> _myChallenges = [];
  bool _isLoadingChallenges = false;

  @override
  void initState() {
    super.initState();
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
          SnackBar(content: Text('Error al cargar piques: $e')),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoadingChallenges) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_myChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            const Text(
              'No tienes piques activos.',
              style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Desafía a tus amigos para ver quién levanta más!',
              style: TextStyle(color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showUpdateRecordDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Actualizar mis marcas'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myChallenges.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tus Piques',
                    style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _showUpdateRecordDialog,
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    label: const Text('Mis Marcas', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            );
          }

          final challenge = _myChallenges[index - 1];
          return _buildChallengeCard(challenge);
        },
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    challenge.challenger.username[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('vs', style: TextStyle(color: AppColors.secondary, fontStyle: FontStyle.italic)),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    challenge.challenged.username[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(challenge.status),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              challenge.exerciseName,
              style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeightInfo(challenge.challenger.username, challenge.challengerWeight),
                const Icon(Icons.bolt, color: Colors.orange),
                _buildWeightInfo(challenge.challenged.username, challenge.challengedWeight),
              ],
            ),
            if (challenge.status == ChallengeStatus.PENDING) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectChallenge(challenge.id),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptChallenge(challenge.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              ),
            ],
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
          style: const TextStyle(color: AppColors.secondary, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${weight.toStringAsFixed(1)} kg',
          style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ChallengeStatus status) {
    Color color;
    String text;
    switch (status) {
      case ChallengeStatus.PENDING:
        color = Colors.orange;
        text = 'PENDIENTE';
        break;
      case ChallengeStatus.ACCEPTED:
        color = Colors.green;
        text = 'ACTIVO';
        break;
      case ChallengeStatus.REJECTED:
        color = Colors.red;
        text = 'RECHAZADO';
        break;
      case ChallengeStatus.FINISHED:
        color = AppColors.primary;
        text = 'FINALIZADO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectChallenge(String id) async {
    try {
      await _challengeService.rejectChallenge(id);
      _loadChallenges();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showUpdateRecordDialog() {
    final TextEditingController exerciseController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Actualizar Marca Personal', style: TextStyle(color: AppColors.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: exerciseController,
              decoration: const InputDecoration(
                labelText: 'Ejercicio (ej: Press Banca)',
                labelStyle: TextStyle(color: AppColors.secondary),
              ),
              style: const TextStyle(color: AppColors.textMain),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                labelStyle: TextStyle(color: AppColors.secondary),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textMain),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.secondary)),
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marca actualizada')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
