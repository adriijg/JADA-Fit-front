import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../../../../l10n/app_localizations.dart';
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
            content: Text(AppLocalizations.of(context)!.socialErrorDetails(e.toString())),
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
      appBar: AppBar(
        title: Text(
          _profile?.username ?? AppLocalizations.of(context)!.profileTitle,
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textMain),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (_error != null && _profile == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: AppColors.error,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.secondary),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.refresh, size: 18),
                label: Text(AppLocalizations.of(context)!.nutritionRetry),
              ),
            ],
          ),
        ),
      );
    }

    if (_profile == null) return SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: context.colors.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: 24),

                  // Profile picture
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          context.colors.primary.withValues(alpha: 0.4),
                          context.colors.secondary.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundImage:
                          _profile!.profilePictureUrl != null &&
                                  _profile!.profilePictureUrl!.isNotEmpty
                              ? NetworkImage(ImageUrlResolver.resolve(_profile!.profilePictureUrl!))
                              : null,
                      child: _profile!.profilePictureUrl == null ||
                              _profile!.profilePictureUrl!.isEmpty
                          ? Text(
                              _profile!.username[0].toUpperCase(),
                              style: TextStyle(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 14),

                  // Username
                  Text(
                    '@${_profile!.username}',
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  // Bio
                  if (_profile!.bio != null &&
                      _profile!.bio!.isNotEmpty) ...[
                    SizedBox(height: 6),
                    Text(
                      _profile!.bio!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colors.textMain.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],

                  SizedBox(height: 20),

                  // Stats row
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.colors.divider.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(
                          value: '${_posts.length}',
                          label: AppLocalizations.of(context)!.socialPosts,
                        ),
                        Container(
                          width: 0.5,
                          height: 30,
                          color: context.colors.divider.withValues(alpha: 0.4),
                        ),
                        _StatColumn(
                          value: _profile!.followersCount.toString(),
                          label: AppLocalizations.of(context)!.socialFollowers,
                        ),
                        Container(
                          width: 0.5,
                          height: 30,
                          color: context.colors.divider.withValues(alpha: 0.4),
                        ),
                        _StatColumn(
                          value: _profile!.followingCount.toString(),
                          label: AppLocalizations.of(context)!.socialFollowing,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),

                  // Follow button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          _isProcessingFollow ? null : _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _profile!.isFollowing
                            ? context.colors.surface
                            : context.colors.primary,
                        foregroundColor: _profile!.isFollowing
                            ? context.colors.textMain
                            : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: _profile!.isFollowing
                              ? BorderSide(
                                  color: context.colors.divider
                                      .withValues(alpha: 0.4),
                                )
                              : BorderSide.none,
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessingFollow
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.colors.primary,
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
                                SizedBox(width: 8),
                                Text(
                                  _profile!.isFollowing
                                      ? AppLocalizations.of(context)!.socialUnfollow
                                      : AppLocalizations.of(context)!.socialFollow,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (_profile!.isFollowing) ...[
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _showChallengeDialog,
                        icon: Icon(Icons.emoji_events_outlined, color: context.colors.primary, size: 18),
                        label: Text(
                          AppLocalizations.of(context)!.socialChallengeUser,
                          style: TextStyle(
                            color: context.colors.textMain,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.primary,
                          side: BorderSide(
                            color: context.colors.primary.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 20),

                  // Progress visibility indicator
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.colors.divider.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _profile!.shareProgress
                              ? Icons.insights_rounded
                              : Icons.lock_outline_rounded,
                          color: _profile!.shareProgress
                              ? context.colors.primary
                              : context.colors.secondary,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child:                           Text(
                            _profile!.shareProgress
                                ? AppLocalizations.of(context)!.socialProgressShared
                                : AppLocalizations.of(context)!.socialProgressPrivate,
                            style: TextStyle(
                              color: _profile!.shareProgress
                                  ? context.colors.textMain
                                  : context.colors.secondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Posts section header
                  if (_posts.isNotEmpty)
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                context.colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.grid_view_rounded,
                                color: context.colors.primary,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context)!.socialPosts,
                                style: TextStyle(
                                  color: context.colors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 12),
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
                              context.colors.secondary.withValues(alpha: 0.4),
                          size: 36,
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.socialNoPostsYet,
                          style: TextStyle(
                            color: context.colors.secondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = _posts[index];
                        return ClipRRect(
                          borderRadius: index == 0
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(8))
                              : index == 2
                                  ? BorderRadius.only(
                                      topRight: Radius.circular(8))
                                  : BorderRadius.zero,
                          child: Builder(
                            builder: (context) {
                              Widget errorPlaceholder() {
                                return Container(
                                  color: context.colors.inputBackground,
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: context.colors.secondary,
                                      size: 24,
                                    ),
                                  ),
                                );
                              }

                              final imageUrl = ImageUrlResolver.resolve(post.imageUrl);
                              return imageUrl.startsWith('http')
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => errorPlaceholder(),
                                    )
                                  : Image.file(
                                      File(imageUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => errorPlaceholder(),
                                    );
                            },
                          ),
                        );
                      },
                      childCount: _posts.length,
                    ),
                  ),
                ),

          SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _showChallengeDialog() {
    final TextEditingController exerciseController = TextEditingController();
    final TextEditingController targetWeightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.socialChallengeUserTitle(_profile!.username), style: TextStyle(color: context.colors.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.socialPickExercise,
              style: TextStyle(color: context.colors.secondary, fontSize: 14),
            ),
            SizedBox(height: 16),
            TextField(
              controller: exerciseController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.socialExerciseHint,
                hintStyle: TextStyle(color: context.colors.secondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.colors.divider)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.colors.primary)),
              ),
              style: TextStyle(color: context.colors.textMain),
            ),
            SizedBox(height: 16),
            TextField(
              controller: targetWeightController,
              decoration: InputDecoration(
                hintText: 'Peso objetivo para ganar (kg)',
                hintStyle: TextStyle(color: context.colors.secondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.colors.divider)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.colors.primary)),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: context.colors.textMain),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.nutritionCancel, style: TextStyle(color: context.colors.secondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final exercise = exerciseController.text;
              final targetWeight = double.tryParse(
                targetWeightController.text.replaceAll(',', '.'),
              );
              if (exercise.isNotEmpty && targetWeight != null && targetWeight > 0) {
                try {
                  await _challengeService.createChallenge(widget.userId, exercise, targetWeight);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.socialChallengeSent)),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.socialErrorDetails(e.toString()))),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.black,
            ),
            child: Text(AppLocalizations.of(context)!.socialSendChallenge),
          ),
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
          style: TextStyle(
            color: context.colors.textMain,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: context.colors.secondary.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
