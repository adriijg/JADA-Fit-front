import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ai/presentation/providers/ai_provider.dart';
import '../../../auth/data/models/user_account_model.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../social/data/services/social_service.dart' as es_jadafit_social_service;
import '../../../../core/widgets/app_card.dart';
import '../../../fitness_profile/presentation/screens/fitness_profile_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  bool isLoading = true;
  String? errorMessage;
  UserAccountModel? user;

  @override
  void initState() {
    super.initState();
    _loadUserAccount();
  }

  Future<void> _loadUserAccount() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final currentUser = await _authService.getCurrentUser();

      if (!mounted) return;

      setState(() {
        user = currentUser;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = AppLocalizations.of(context)!.profileError;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    context.read<AiProvider>().clearMessages();
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _showComingSoonMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _formatCreatedAt(DateTime? date) {
    if (date == null) return 'No disponible';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: context.colors.textMain,
        ),
        title: Text(
          AppLocalizations.of(context)!.profileTitle,
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: context.colors.primary,
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.profileLoading,
              style: TextStyle(
                color: context.colors.textMain,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: _ErrorCard(
          message: errorMessage!,
          onRetry: _loadUserAccount,
        ),
      );
    }

    final currentUser = user;

    if (currentUser == null) {
      return Center(
        child: _ErrorCard(
          message: 'No se pudo cargar tu cuenta.',
          onRetry: _loadUserAccount,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _AccountHeaderCard(user: currentUser),
          SizedBox(height: 24),
          _AccountInfoCard(
            username: currentUser.username,
            email: currentUser.email,
            createdAt: _formatCreatedAt(currentUser.createdAt),
          ),
          SizedBox(height: 24),
          _AccountOptionsCard(
            user: currentUser,
            onSettings: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },
            onFitnessProfile: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FitnessProfileScreen(),
                ),
              );
            },
            onPrivacyChanged: _loadUserAccount,
            onIntegrations: () {
              _showComingSoonMessage(AppLocalizations.of(context)!.settingsIntegrationsSoon);
            },
            onLogout: _logout,
          ),
        ],
      ),
    );
  }
}

class _AccountHeaderCard extends StatelessWidget {
  const _AccountHeaderCard({
    required this.user,
  });

  final UserAccountModel user;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      borderRadius: 28,
      padding: EdgeInsets.all(26),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.inputBackground,
              border: Border.all(
                color: context.colors.primary,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              color: context.colors.primary,
              size: 48,
            ),
          ),
          SizedBox(height: 18),
          Text(
            user.username,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            user.email,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 14,
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  const _AccountInfoCard({
    required this.username,
    required this.email,
    required this.createdAt,
  });

  final String username;
  final String email;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      borderRadius: 24,
      padding: EdgeInsets.all(22),
      child: Column(
        children: [
          _AccountInfoRow(
            icon: Icons.badge_outlined,
            label: 'Usuario',
            value: username,
          ),
          const _AccountDivider(),
          _AccountInfoRow(
            icon: Icons.email_outlined,
            label: AppLocalizations.of(context)!.profileEmailLabel,
            value: email,
          ),
          const _AccountDivider(),
          _AccountInfoRow(
            icon: Icons.calendar_month_outlined,
            label: 'Cuenta creada',
            value: createdAt,
          ),
        ],
      ),
    );
  }
}

class _AccountDivider extends StatelessWidget {
  const _AccountDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Divider(
        color: context.colors.divider,
        height: 1,
      ),
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  const _AccountInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppCardIcon(
          icon: icon,
          size: 44,
          borderRadius: 16,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  color: context.colors.textMain,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountOptionsCard extends StatefulWidget {
  const _AccountOptionsCard({
    required this.user,
    required this.onSettings,
    required this.onFitnessProfile,
    required this.onIntegrations,
    required this.onLogout,
    required this.onPrivacyChanged,
  });

  final UserAccountModel user;
  final VoidCallback onSettings;
  final VoidCallback onFitnessProfile;
  final VoidCallback onIntegrations;
  final VoidCallback onLogout;
  final VoidCallback onPrivacyChanged;

  @override
  State<_AccountOptionsCard> createState() => _AccountOptionsCardState();
}

class _AccountOptionsCardState extends State<_AccountOptionsCard> {
  late bool _shareProgress;
  bool _isUpdatingPrivacy = false;

  @override
  void initState() {
    super.initState();
    _shareProgress = widget.user.shareProgress;
  }

  @override
  void didUpdateWidget(covariant _AccountOptionsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.shareProgress != widget.user.shareProgress) {
      _shareProgress = widget.user.shareProgress;
    }
  }

  Future<void> _togglePrivacy(bool value) async {
    setState(() {
      _isUpdatingPrivacy = true;
    });

    try {
      final socialService = es_jadafit_social_service.SocialService();
      await socialService.updatePrivacy(value);
      setState(() {
        _shareProgress = value;
      });
      widget.onPrivacyChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profilePrivacyUpdateError(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPrivacy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      borderRadius: 24,
      padding: EdgeInsets.all(18),
      child: Column(
        children: [
          _AccountOptionTile(
            icon: Icons.settings_outlined,
            title: AppLocalizations.of(context)!.settingsTitle,
            subtitle: AppLocalizations.of(context)!.settingsAppPreferences,
            onTap: widget.onSettings,
          ),
          SizedBox(height: 10),
          _PrivacyToggleTile(
            icon: Icons.lock_outline,
            title: AppLocalizations.of(context)!.settingsShareProgress,
            subtitle: 'Permitir a otros ver tu actividad',
            value: _shareProgress,
            isLoading: _isUpdatingPrivacy,
            onChanged: _togglePrivacy,
          ),
          SizedBox(height: 10),
          _AccountOptionTile(
            icon: Icons.favorite_border,
            title: AppLocalizations.of(context)!.settingsIntegrations,
            subtitle: AppLocalizations.of(context)!.settingsIntegrationsSoon,
            onTap: widget.onIntegrations,
          ),
          SizedBox(height: 10),
          _AccountOptionTile(
            icon: Icons.monitor_heart_outlined,
            title: AppLocalizations.of(context)!.settingsPhysicalData,
            subtitle: AppLocalizations.of(context)!.profilePhysicalDataSubtitle,
            onTap: widget.onFitnessProfile,
          ),
          SizedBox(height: 10),
          _AccountOptionTile(
            icon: Icons.logout,
            title: AppLocalizations.of(context)!.settingsLogout,
            subtitle: 'Salir de tu cuenta',
            isDestructive: true,
            onTap: widget.onLogout,
          ),
        ],
      ),
    );
  }
}

class _PrivacyToggleTile extends StatelessWidget {
  const _PrivacyToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isLoading,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard.input(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: context.colors.primary,
            size: 24,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.colors.secondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary),
              ),
            )
          else
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: context.colors.primary,
            ),
        ],
      ),
    );
  }
}

class _AccountOptionTile extends StatelessWidget {
  const _AccountOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDestructive ? AppColors.error : context.colors.primary;
    final titleColor = isDestructive ? AppColors.error : context.colors.textMain;

    return AppCard.input(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.colors.secondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDestructive ? AppColors.error : context.colors.secondary,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: 24,
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 42,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.nutritionRetry,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
