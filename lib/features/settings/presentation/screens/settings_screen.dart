import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../presentation/providers/settings_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Colors.transparent,
        foregroundColor: context.colors.textMain,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return Column(
              children: [
                _SectionTitle(title: l10n.settingsAppearance),
                SizedBox(height: 10),
                AppCard.elevated(
                  borderRadius: 20,
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: [
                      _ThemeSelector(settings: settings),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _SectionTitle(title: l10n.settingsLanguage),
                SizedBox(height: 10),
                AppCard.elevated(
                  borderRadius: 20,
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: [
                      _LanguageSelector(settings: settings),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _SectionTitle(title: l10n.settingsUnits),
                SizedBox(height: 10),
                AppCard.elevated(
                  borderRadius: 20,
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: [
                      _SettingsToggleTile(
                        icon: Icons.monitor_weight_outlined,
                        title: l10n.settingsImperialUnits,
                        subtitle: l10n.settingsImperialUnitsDesc,
                        value: settings.isImperial,
                        onChanged: (v) => settings.setImperial(v),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _SectionTitle(title: l10n.settingsNotifications),
                SizedBox(height: 10),
                AppCard.elevated(
                  borderRadius: 20,
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: [
                      _SettingsToggleTile(
                        icon: Icons.smart_toy_outlined,
                        title: l10n.settingsAiAssistant,
                        subtitle: l10n.settingsAiAssistantDesc,
                        value: settings.aiNotificationsEnabled,
                        onChanged: (v) => settings.setAiNotifications(v),
                      ),
                      _SettingsDivider(),
                      _SettingsToggleTile(
                        icon: Icons.fitness_center_outlined,
                        title: l10n.settingsWorkoutReminders,
                        subtitle: l10n.settingsWorkoutRemindersDesc,
                        value: settings.workoutRemindersEnabled,
                        onChanged: (v) async {
                          settings.setWorkoutReminders(v);
                          final notif = NotificationService.instance;
                          if (v) {
                            await notif.scheduleWorkoutReminder();
                          } else {
                            await notif.cancelWorkoutReminder();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _SectionTitle(title: l10n.settingsInfo),
                SizedBox(height: 10),
                AppCard.elevated(
                  borderRadius: 20,
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: [
                      _SettingsOptionTile(
                        icon: Icons.info_outline,
                        title: l10n.settingsAbout,
                        subtitle: l10n.settingsVersion,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AboutScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: TextStyle(
            color: context.colors.secondary.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.settings});
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.brightness_6_outlined, color: context.colors.primary, size: 24),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.settingsTheme,
              style: TextStyle(
                color: context.colors.textMain,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _SettingsChip(
            label: l10n.settingsThemeDark,
            icon: Icons.dark_mode,
            selected: settings.themeMode == ThemeMode.dark,
            onTap: () => settings.setThemeMode(ThemeMode.dark),
          ),
          SizedBox(width: 6),
          _SettingsChip(
            label: l10n.settingsThemeLight,
            icon: Icons.light_mode,
            selected: settings.themeMode == ThemeMode.light,
            onTap: () => settings.setThemeMode(ThemeMode.light),
          ),
          SizedBox(width: 6),
          _SettingsChip(
            label: l10n.settingsThemeSystem,
            icon: Icons.brightness_auto,
            selected: settings.themeMode == ThemeMode.system,
            onTap: () => settings.setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.settings});
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLang = settings.locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.language_outlined, color: context.colors.primary, size: 24),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.settingsLanguage,
              style: TextStyle(
                color: context.colors.textMain,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _LanguageFlagChip(
            flag: '🇪🇸',
            label: l10n.settingsLanguageEs,
            selected: currentLang == 'es',
            onTap: () => settings.setLocale(const Locale('es')),
          ),
          SizedBox(width: 8),
          _LanguageFlagChip(
            flag: '🇬🇧',
            label: l10n.settingsLanguageEn,
            selected: currentLang == 'en',
            onTap: () => settings.setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }
}

class _LanguageFlagChip extends StatelessWidget {
  const _LanguageFlagChip({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? context.colors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? context.colors.primary.withValues(alpha: 0.4) : context.colors.divider.withValues(alpha: 0.3),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? context.colors.textMain : context.colors.textMain.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsChip extends StatelessWidget {
  const _SettingsChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? context.colors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? context.colors.primary.withOpacity(0.4) : context.colors.divider.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? context.colors.primary : context.colors.textMain.withOpacity(0.5)),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? context.colors.primary : context.colors.textMain.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard.input(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 24),
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
                    color: context.colors.secondary.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 28,
            child: Switch(
              value: value,
              activeThumbColor: context.colors.background,
              activeTrackColor: context.colors.primary,
              inactiveThumbColor: context.colors.textMain.withOpacity(0.25),
              inactiveTrackColor: context.colors.divider,
              trackOutlineColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsOptionTile extends StatelessWidget {
  const _SettingsOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard.input(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 24),
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
                    color: context.colors.secondary.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.colors.secondary.withOpacity(0.5)),
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Divider(
        color: context.colors.divider.withOpacity(0.3),
        height: 1,
      ),
    );
  }
}
