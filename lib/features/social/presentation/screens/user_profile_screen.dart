import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/user_profile.dart';
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
  UserProfile? _profile;
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
      final profile = await _socialService.getUserProfile(widget.userId);
      if (mounted) {
        setState(() {
          _profile = profile;
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
          SnackBar(content: Text('Error: $e')),
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
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
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
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_profile == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              _profile!.username[0].toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '@${_profile!.username}',
            style: const TextStyle(color: AppColors.textMain, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Seguidores', _profile!.followersCount.toString()),
              _buildStatColumn('Siguiendo', _profile!.followingCount.toString()),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessingFollow ? null : _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _profile!.isFollowing ? AppColors.surface : AppColors.primary,
                foregroundColor: _profile!.isFollowing ? AppColors.textMain : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: _profile!.isFollowing 
                      ? BorderSide(color: AppColors.divider.withOpacity(0.4)) 
                      : BorderSide.none,
                ),
              ),
              child: _isProcessingFollow
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _profile!.isFollowing ? 'Dejar de seguir' : 'Seguir',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          if (_profile!.isFollowing) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _showChallengeDialog,
                icon: const Icon(Icons.emoji_events_outlined, color: AppColors.primary),
                label: const Text('¡Desafiar a un pique!', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (_profile!.shareProgress)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.insights, color: AppColors.primary),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Este usuario comparte su progreso.',
                      style: TextStyle(color: AppColors.textMain),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, color: AppColors.secondary),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Este usuario mantiene su progreso privado.',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.secondary, fontSize: 14),
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
