import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart' show File;

import '../../../../l10n/app_localizations.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_picker.dart' as file_picker;
import '../../../../core/utils/image_url_resolver.dart';
import '../../data/models/post.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/post_service.dart';
import '../../data/services/social_service.dart';
import '../../data/services/story_service.dart';
import 'post_detail_screen.dart';

class MySocialProfileScreen extends StatefulWidget {
  const MySocialProfileScreen({super.key, this.refreshVersion = 0});

  final int refreshVersion;

  @override
  State<MySocialProfileScreen> createState() => _MySocialProfileScreenState();
}

class _MySocialProfileScreenState extends State<MySocialProfileScreen> {
  final PostService _postService = PostService();
  final SocialService _socialService = SocialService();
  final SecureStorageService _storageService = SecureStorageService();

  Map<String, dynamic>? _currentUser;
  UserProfile? _socialProfile;
  List<Post> _myPosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didUpdateWidget(covariant MySocialProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshVersion != oldWidget.refreshVersion) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception(AppLocalizations.of(context)!.sessionNotActive);

      // Get current user info
      final meResponse = await http.get(
        Uri.parse(ApiEndpoints.me),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (meResponse.statusCode == 200) {
        final userData = jsonDecode(meResponse.body) as Map<String, dynamic>;
        UserProfile? socialProfile;

        try {
          socialProfile = await _socialService.getUserProfile(
            userData['id'].toString(),
          );
        } catch (_) {
          // Keep the profile usable even if social stats cannot be loaded.
        }

        // Get user posts
        List<Post> posts = [];
        try {
          posts = await _postService.getUserPosts(userData['id']);
        } catch (_) {
          // User might not have posts yet
        }

        if (mounted) {
          setState(() {
            _currentUser = userData;
            _socialProfile = socialProfile;
            _myPosts = posts;
          });
        }
      } else {
        throw Exception(AppLocalizations.of(context)!.socialProfileLoadError);
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

  Future<String?> _pickImageFromGallery() async {
    if (kIsWeb) {
      try {
        return await file_picker.pickImage();
      } catch (e) {
        debugPrint('Web file picker error: $e');
        return null;
      }
    }
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile?.path;
  }

  void _showCreatePostDialog() {
    final captionController = TextEditingController();
    String? selectedImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final l10n = AppLocalizations.of(context)!;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    l10n.socialNewPost,
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final path = await _pickImageFromGallery();
                        if (path != null) {
                          setModalState(() {
                            selectedImagePath = path;
                          });
                        }
                      } catch (_) {}
                    },
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: context.colors.inputBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: context.colors.inputBorder.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: selectedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: kIsWeb
                                  ? Image.network(
                                      selectedImagePath!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Image.file(
                                      File(selectedImagePath!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: context.colors.secondary,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  l10n.socialPickFromGallery,
                                  style: TextStyle(
                                    color: context.colors.secondary.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 14),
                  _buildInputField(
                    controller: captionController,
                    label: l10n.socialDescriptionOptional,
                    icon: Icons.edit_outlined,
                    maxLines: 3,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedImagePath == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.socialSelectImageFirst),
                            ),
                          );
                          return;
                        }

                        try {
                          await _postService.createPost(
                            imagePath: selectedImagePath!,
                            caption: captionController.text.trim().isNotEmpty
                                ? captionController.text.trim()
                                : null,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            _loadProfile();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.socialPostCreated),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.socialErrorDetails(e.toString())),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.socialPublish,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateStoryDialog() {
    String? selectedImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final l10n = AppLocalizations.of(context)!;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    l10n.socialNewStory,
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    l10n.socialStoryExpires,
                    style: TextStyle(
                      color: context.colors.secondary.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final path = await _pickImageFromGallery();
                        if (path != null) {
                          setModalState(() {
                            selectedImagePath = path;
                          });
                        }
                      } catch (_) {}
                    },
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: context.colors.inputBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: context.colors.inputBorder.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: selectedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: kIsWeb
                                  ? Image.network(
                                      selectedImagePath!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Image.file(
                                      File(selectedImagePath!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: context.colors.secondary,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  l10n.socialPickFromGallery,
                                  style: TextStyle(
                                    color: context.colors.secondary.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedImagePath == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.socialSelectImageFirst),
                            ),
                          );
                          return;
                        }

                        try {
                          final storyService = StoryService();
                          await storyService.createStory(
                            imageUrl: selectedImagePath!,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.socialStoryCreated),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.socialErrorDetails(e.toString())),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.secondary,
                        foregroundColor: context.colors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.socialUploadStory,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProfileDialog() {
    final bioController = TextEditingController(
      text: _currentUser?['bio'] ?? '',
    );
    String? selectedImagePath = _currentUser?['profilePictureUrl'];
    bool isNewImage = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final l10n = AppLocalizations.of(context)!;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    l10n.socialEditProfile,
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final path = await _pickImageFromGallery();
                        if (path != null) {
                          setModalState(() {
                            selectedImagePath = path;
                            isNewImage = true;
                          });
                        }
                      } catch (_) {}
                    },
                    child: Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.inputBackground,
                              border: Border.all(
                                color: context.colors.inputBorder.withValues(
                                  alpha: 0.5,
                                ),
                                width: 0.8,
                              ),
                            ),
                            child: ClipOval(
                              child:
                                  selectedImagePath != null &&
                                      selectedImagePath!.isNotEmpty
                                  ? (isNewImage
                                        ? (kIsWeb
                                              ? Image.network(
                                                  selectedImagePath!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, _, _) =>
                                                      Icon(
                                                        Icons.person,
                                                        size: 50,
                                                        color: context.colors.secondary,
                                                      ),
                                                )
                                              : Image.file(
                                                  File(selectedImagePath!),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, _, _) =>
                                                      Icon(
                                                        Icons.person,
                                                        size: 50,
                                                        color: context.colors.secondary,
                                                      ),
                                                ))
                                        : Image.network(
                                            ImageUrlResolver.resolve(
                                              selectedImagePath!,
                                            ),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: context.colors.secondary,
                                                ),
                                          ))
                                  : Icon(
                                      Icons.person,
                                      color: context.colors.secondary,
                                      size: 50,
                                    ),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.colors.background,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: context.colors.background,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildInputField(
                    controller: bioController,
                    label: l10n.socialBio,
                    icon: Icons.info_outline,
                    maxLines: 3,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _socialService.updateProfile(
                            bio: bioController.text.trim(),
                            profilePictureUrl: selectedImagePath,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            _loadProfile();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.socialProfileUpdated),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.socialErrorDetails(e.toString())),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.socialSave,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.colors.inputBorder.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: context.colors.textMain, fontSize: 14),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: context.colors.secondary.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: context.colors.secondary, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (_error != null) {
      return Center(
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
            SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadProfile,
              icon: Icon(Icons.refresh, color: context.colors.primary),
              label: Text(
                l10n.nutritionRetry,
                style: TextStyle(color: context.colors.primary),
              ),
            ),
          ],
        ),
      );
    }

    if (_currentUser == null) return SizedBox.shrink();

    final username = _currentUser!['username'] ?? l10n.socialUserFallback;
    final bio = _currentUser!['bio'] as String?;
    final profilePicUrl = _currentUser!['profilePictureUrl'] as String?;
    final followersCount = _socialProfile?.followersCount ?? 0;
    final followingCount = _socialProfile?.followingCount ?? 0;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: context.colors.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 20),

                // Profile picture
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
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
                            profilePicUrl != null && profilePicUrl.isNotEmpty
                            ? NetworkImage(
                                ImageUrlResolver.resolve(profilePicUrl),
                              )
                            : null,
                        child: profilePicUrl == null || profilePicUrl.isEmpty
                            ? Text(
                                username[0].toUpperCase(),
                                style: TextStyle(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.background,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 14,
                        color: context.colors.background,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),

                // Username
                Text(
                  '@$username',
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                // Bio
                if (bio != null && bio.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colors.textMain.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 20),

                // Stats row
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 0),
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
                      _StatItem(value: '${_myPosts.length}', label: l10n.socialPosts),
                      Container(
                        width: 0.5,
                        height: 30,
                        color: context.colors.divider.withValues(alpha: 0.4),
                      ),
                      _StatItem(value: '$followersCount', label: l10n.socialFollowers),
                      Container(
                        width: 0.5,
                        height: 30,
                        color: context.colors.divider.withValues(alpha: 0.4),
                      ),
                      _StatItem(value: '$followingCount', label: l10n.socialFollowing),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: l10n.socialEditProfile,
                        icon: Icons.edit_outlined,
                        color: context.colors.primary,
                        onTap: _showEditProfileDialog,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: l10n.socialNewPost,
                        icon: Icons.add_photo_alternate_outlined,
                        color: context.colors.secondary,
                        onTap: _showCreatePostDialog,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: l10n.socialNewStory,
                        icon: Icons.auto_awesome,
                        color: context.colors.tertiary,
                        onTap: _showCreateStoryDialog,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Section header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
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
                            l10n.socialMyPosts,
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

          // Posts grid
          _myPosts.isEmpty
              ? SliverToBoxAdapter(
                  child: Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          color: context.colors.secondary.withValues(alpha: 0.4),
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.socialNoPosts,
                          style: TextStyle(
                            color: context.colors.secondary,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.socialShareProgressCommunity,
                          style: TextStyle(
                            color: context.colors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = _myPosts[index];
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
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(post: post, currentUserId: _currentUser!['id']),
                          ),
                        );
                      },
                      child: imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  errorPlaceholder(),
                            )
                          : Image.file(
                              File(imageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  errorPlaceholder(),
                            ),
                    );
                  }, childCount: _myPosts.length),
                ),

          SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ─── Stat Item ───────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

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

// ─── Action Button ───────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
