import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/post.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/post_service.dart';
import '../../data/services/social_service.dart';
import '../../data/services/challenge_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final SocialService _socialService = SocialService();
  final ChallengeService _challengeService = ChallengeService();
  final PostService _postService = PostService();
  UserProfile? _profile;
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;
  bool _isProcessingFollow = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _socialService.getUserProfile(widget.userId),
        _postService.getUserPosts(widget.userId),
      ]);

      if (mounted) {
        setState(() {
          _profile = results[0] as UserProfile;
          _posts = results[1] as List<Post>;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          // Try to load profile at least even if posts fail
        });
      }
      // Try profile alone if Future.wait failed
      try {
        final profile = await _socialService.getUserProfile(widget.userId);
        if (mounted) {
          setState(() {
            _profile = profile;
            _error = null;
          });
        }
      } catch (_) {}
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (_profile == null || _isProcessingFollow) return;

    setState(() {
      _isProcessingFollow = true;
    });

    try {
      if (_profile!.isFollowing) {
        await _socialService.unfollowUser(widget.userId);
      } else {
        await _socialService.followUser(widget.userId);
      }
      
      // Reload profile to get updated counts and status
      await _loadProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingFollow = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _profile?.username ?? 'Perfil',
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null && _profile == null) {
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
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.secondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_profile == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Profile picture
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.4),
                          AppColors.secondary.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: AppColors.surface,
                      backgroundImage:
                          _profile!.profilePictureUrl != null &&
                                  _profile!.profilePictureUrl!.isNotEmpty
                              ? NetworkImage(_profile!.profilePictureUrl!)
                              : null,
                      child: _profile!.profilePictureUrl == null ||
                              _profile!.profilePictureUrl!.isEmpty
                          ? Text(
                              _profile!.username[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Username
                  Text(
                    '@${_profile!.username}',
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  // Bio
                  if (_profile!.bio != null &&
                      _profile!.bio!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _profile!.bio!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMain.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Stats row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(
                          value: '${_posts.length}',
                          label: 'Posts',
                        ),
                        Container(
                          width: 0.5,
                          height: 30,
                          color: AppColors.divider.withValues(alpha: 0.4),
                        ),
                        _StatColumn(
                          value: _profile!.followersCount.toString(),
                          label: 'Seguidores',
                        ),
                        Container(
                          width: 0.5,
                          height: 30,
                          color: AppColors.divider.withValues(alpha: 0.4),
                        ),
                        _StatColumn(
                          value: _profile!.followingCount.toString(),
                          label: 'Siguiendo',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Follow button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          _isProcessingFollow ? null : _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _profile!.isFollowing
                            ? AppColors.surface
                            : AppColors.primary,
                        foregroundColor: _profile!.isFollowing
                            ? AppColors.textMain
                            : AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: _profile!.isFollowing
                              ? BorderSide(
                                  color: AppColors.divider
                                      .withValues(alpha: 0.4),
                                )
                              : BorderSide.none,
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessingFollow
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _profile!.isFollowing
                                      ? Icons.person_remove_outlined
                                      : Icons.person_add_outlined,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _profile!.isFollowing
                                      ? 'Dejar de seguir'
                                      : 'Seguir',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (_profile!.isFollowing) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _showChallengeDialog,
                        icon: const Icon(Icons.emoji_events_outlined, color: AppColors.primary, size: 18),
                        label: const Text(
                          '¡Desafiar a un pique!',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Progress visibility indicator
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _profile!.shareProgress
                              ? Icons.insights_rounded
                              : Icons.lock_outline_rounded,
                          color: _profile!.shareProgress
                              ? AppColors.primary
                              : AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _profile!.shareProgress
                                ? 'Este usuario comparte su progreso'
                                : 'Progreso privado',
                            style: TextStyle(
                              color: _profile!.shareProgress
                                  ? AppColors.textMain
                                  : AppColors.secondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Posts section header
                  if (_posts.isNotEmpty)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.grid_view_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Publicaciones',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Posts grid
          _posts.isEmpty
              ? SliverToBoxAdapter(
                  child: Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          color:
                              AppColors.secondary.withValues(alpha: 0.4),
                          size: 36,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Aún no hay publicaciones',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = _posts[index];
                        return ClipRRect(
                          borderRadius: index == 0
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(8))
                              : index == 2
                                  ? const BorderRadius.only(
                                      topRight: Radius.circular(8))
                                  : BorderRadius.zero,
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
                                    size: 24,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: _posts.length,
                    ),
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ─── Stat Column ─────────────────────────────────────────────────────────────

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textMain,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: AppColors.secondary.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showChallengeDialog() {
    final TextEditingController exerciseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Desafiar a ${_profile!.username}', style: const TextStyle(color: AppColors.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿En qué ejercicio quieres competir?',
              style: TextStyle(color: AppColors.secondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: exerciseController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Ej: Press Banca, Sentadilla...',
                hintStyle: TextStyle(color: AppColors.secondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
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
              if (exercise.isNotEmpty) {
                try {
                  await _challengeService.createChallenge(widget.userId, exercise);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Desafío enviado con éxito!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Enviar Desafío'),
          ),
        ],
      ),
    );
  }
}
