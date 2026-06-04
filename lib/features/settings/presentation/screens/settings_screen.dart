import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../presentation/providers/settings_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuraci\u00f3n'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textMain,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return Column(
              children: [
                _SectionTitle(title: 'Apariencia'),
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
                _SectionTitle(title: 'Unidades'),
                SizedBox(height: 10),
                AppCard.elevated(
                  borderRadius: 20,
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: [
                      _SettingsToggleTile(
                        icon: Icons.monitor_weight_outlined,
                        title: 'Unidades imperiales',
                        subtitle: 'Mostrar peso y altura en lbs / ft',
                        value: settings.isImperial,
                        onChanged: (v) => settings.setImperial(v),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _SectionTitle(title: 'Notificaciones'),
                SizedBox(height: 10),
                AppCard.elevated(
                  borderRadius: 20,
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: [
                      _SettingsToggleTile(
                        icon: Icons.smart_toy_outlined,
                        title: 'Asistente IA',
                        subtitle: 'Notificaciones cuando la IA responda',
                        value: settings.aiNotificationsEnabled,
                        onChanged: (v) => settings.setAiNotifications(v),
                      ),
                      _SettingsDivider(),
                      _SettingsToggleTile(
                        icon: Icons.fitness_center_outlined,
                        title: 'Recordatorio de entrenos',
                        subtitle: 'Recordar entrenar cada d\u00eda',
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
                _SectionTitle(title: 'Informaci\u00f3n'),
                SizedBox(height: 10),
                AppCard.elevated(
                  borderRadius: 20,
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: [
                      _SettingsOptionTile(
                        icon: Icons.info_outline,
                        title: 'Acerca de JADA Fit',
                        subtitle: 'Versi\u00f3n 1.0.0',
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
            color: AppColors.secondary.withOpacity(0.7),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.brightness_6_outlined, color: AppColors.primary, size: 24),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Tema',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _ThemeChip(
            label: 'Oscuro',
            icon: Icons.dark_mode,
            selected: settings.themeMode == ThemeMode.dark,
            onTap: () => settings.setThemeMode(ThemeMode.dark),
          ),
          SizedBox(width: 6),
          _ThemeChip(
            label: 'Claro',
            icon: Icons.light_mode,
            selected: settings.themeMode == ThemeMode.light,
            onTap: () => settings.setThemeMode(ThemeMode.light),
          ),
          SizedBox(width: 6),
          _ThemeChip(
            label: 'Auto',
            icon: Icons.brightness_auto,
            selected: settings.themeMode == ThemeMode.system,
            onTap: () => settings.setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
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
          color: selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary.withOpacity(0.4) : AppColors.divider.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? AppColors.primary : AppColors.textMain.withOpacity(0.5)),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textMain.withOpacity(0.5),
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
          Icon(icon, color: AppColors.primary, size: 24),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.secondary.withOpacity(0.8),
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
              activeThumbColor: AppColors.background,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: AppColors.textMain.withOpacity(0.25),
              inactiveTrackColor: AppColors.divider,
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
          Icon(icon, color: AppColors.primary, size: 24),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.secondary.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.secondary.withOpacity(0.5)),
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
        color: AppColors.divider.withOpacity(0.3),
        height: 1,
      ),
    );
  }
}
