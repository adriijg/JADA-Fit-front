import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/post.dart';
import '../../data/models/user_summary.dart';
import '../../data/services/post_service.dart';
import '../../data/services/social_service.dart';
import 'user_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PostService _postService = PostService();
  final SocialService _socialService = SocialService();
  final TextEditingController _searchController = TextEditingController();

  List<Post> _explorePosts = [];
  List<UserSummary> _searchResults = [];
  bool _isLoadingPosts = true;
  bool _isSearching = false;
  bool _showSearchResults = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExplore();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExplore() async {
    setState(() {
      _isLoadingPosts = true;
      _error = null;
    });

    try {
      final posts = await _postService.getExplore();
      if (mounted) {
        setState(() {
          _explorePosts = posts;
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
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      final results = await _socialService.searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.socialSearchError(e.toString())),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
    });
  }

  void _navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.inputBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.colors.inputBorder.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuarios...',
                hintStyle: TextStyle(
                  color: context.colors.secondary.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: context.colors.secondary,
                  size: 20,
                ),
                suffixIcon: _showSearchResults
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: context.colors.secondary,
                          size: 18,
                        ),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(color: context.colors.textMain, fontSize: 14),
              onSubmitted: _searchUsers,
              onChanged: (value) {
                if (value.isEmpty) _clearSearch();
              },
            ),
          ),
        ),

        // Content
        Expanded(
          child: _showSearchResults
              ? _buildSearchResults()
              : _buildExploreGrid(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_rounded,
              color: context.colors.secondary.withValues(alpha: 0.5),
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'No se encontraron usuarios',
              style: TextStyle(color: context.colors.secondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _UserSearchTile(
          user: user,
          onTap: () => _navigateToProfile(user.id),
        );
      },
    );
  }

  Widget _buildExploreGrid() {
    if (_isLoadingPosts) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 48),
            SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.secondary),
            ),
            SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadExplore,
              icon: Icon(Icons.refresh, color: context.colors.primary),
              label: Text(AppLocalizations.of(context)!.nutritionRetry, style: TextStyle(color: context.colors.primary)),
            ),
          ],
        ),
      );
    }

    if (_explorePosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.colors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.explore_rounded,
                color: context.colors.secondary,
                size: 32,
              ),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.socialNothingToExplore,
              style: TextStyle(
                color: context.colors.textMain,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.socialPublicPostsHere,
              style: TextStyle(color: context.colors.secondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExplore,
      color: context.colors.primary,
      child: GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemCount: _explorePosts.length,
        itemBuilder: (context, index) {
          final post = _explorePosts[index];
          return _ExploreGridTile(post: post);
        },
      ),
    );
  }
}

// ─── User Search Tile ────────────────────────────────────────────────────────

class _UserSearchTile extends StatelessWidget {
  const _UserSearchTile({
    required this.user,
    required this.onTap,
  });

  final UserSummary user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: context.colors.primary.withValues(alpha: 0.15),
        backgroundImage: user.profilePictureUrl != null
            ? NetworkImage(ImageUrlResolver.resolve(user.profilePictureUrl!))
            : null,
        child: user.profilePictureUrl == null
            ? Text(
                user.username[0].toUpperCase(),
                style: TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            : null,
      ),
      title: Text(
        user.username,
        style: TextStyle(
          color: context.colors.textMain,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.colors.secondary.withValues(alpha: 0.5),
      ),
    );
  }
}

// ─── Explore Grid Tile ───────────────────────────────────────────────────────

class _ExploreGridTile extends StatelessWidget {
  const _ExploreGridTile({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Could show post detail in the future
      },
      child: Image.network(
        ImageUrlResolver.resolve(post.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
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
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: context.colors.inputBackground,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: context.colors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
