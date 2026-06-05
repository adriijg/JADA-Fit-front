import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../data/models/fitness_profile_model.dart';
import '../../data/services/fitness_profile_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import 'add_physical_log_screen.dart';
import 'edit_fitness_profile_screen.dart';
import 'fitness_progress_screen.dart';

class FitnessProfileScreen extends StatefulWidget {
  FitnessProfileScreen({super.key});

  @override
  State<FitnessProfileScreen> createState() => _FitnessProfileScreenState();
}

class _FitnessProfileScreenState extends State<FitnessProfileScreen> {
  final FitnessProfileService _fitnessProfileService = FitnessProfileService();

  bool isLoading = true;
  String? errorMessage;
  FitnessProfileModel? fitnessProfile;

  @override
  void initState() {
    super.initState();
    _loadFitnessProfile();
  }

  Future<void> _loadFitnessProfile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedProfile = await _fitnessProfileService.getMyFitnessProfile();

      if (!mounted) return;

      setState(() {
        fitnessProfile = loadedProfile;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'No se pudo cargar tu perfil físico.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _openEditFitnessProfile() async {
    final currentProfile = fitnessProfile;

    if (currentProfile == null) return;

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditFitnessProfileScreen(
          currentProfile: currentProfile,
        ),
      ),
    );

    if (updated == true) {
      await _loadFitnessProfile();
    }
  }

  Future<void> _openAddPhysicalLog() async {
    final currentProfile = fitnessProfile;

    if (currentProfile == null) return;

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddPhysicalLogScreen(
          currentProfile: currentProfile,
        ),
      ),
    );

    if (created == true) {
      await _loadFitnessProfile();
    }
  }

  Future<void> _openFitnessProgress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FitnessProgressScreen(),
      ),
    );

    if (mounted) {
      await _loadFitnessProfile();
    }
  }

  String _formatInt(int? value, String unit) {
    if (value == null) return '--';
    return '$value $unit';
  }

  String _formatGender(String? value) {
    if (value == null || value.trim().isEmpty) return 'Sin configurar';

    switch (value.trim().toUpperCase()) {
      case 'HOMBRE':
        return 'Hombre';
      case 'MUJER':
        return 'Mujer';
      default:
        return value;
    }
  }

  String _formatGoal(String? value) {
    if (value == null || value.trim().isEmpty) return 'Sin configurar';

    switch (value.trim().toUpperCase()) {
      case 'GANAR_MUSCULO':
        return 'Ganar músculo';
      case 'PERDER_GRASA':
        return 'Perder grasa';
      case 'MANTENERSE_ATLETICO':
        return 'Mantenerse atlético/a';
      default:
        return value;
    }
  }

  String _formatUpdatedAt(DateTime? date) {
    if (date == null) return 'No disponible';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year · $hour:$minute';
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
          'Perfil físico',
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFitnessProfile,
          color: context.colors.primary,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return SizedBox(
        height: 500,
        child: Center(
          child: CircularProgressIndicator(
            color: context.colors.primary,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return SizedBox(
        height: 500,
        child: Center(
          child: _ErrorCard(
            message: errorMessage!,
            onRetry: _loadFitnessProfile,
          ),
        ),
      );
    }

    final currentProfile = fitnessProfile;

    if (currentProfile == null) {
      return SizedBox(
        height: 500,
        child: Center(
          child: _ErrorCard(
            message: 'No se pudo cargar tu perfil físico.',
            onRetry: _loadFitnessProfile,
          ),
        ),
      );
    }

    final settings = context.watch<SettingsProvider>();
    final imperial = settings.isImperial;

    return Column(
      children: [
        _FitnessHeaderCard(
          username: currentProfile.username,
          goal: _formatGoal(currentProfile.goal),
          updatedAt: _formatUpdatedAt(currentProfile.updatedAt),
        ),
        SizedBox(height: 24),
        _MainStatsCard(
          weight: UnitConverter.formatWeight(currentProfile.weight, imperial),
          height: UnitConverter.formatHeight(currentProfile.height, imperial),
          age: _formatInt(currentProfile.age, 'a\u00f1os'),
        ),
        SizedBox(height: 18),
        _BodyCompositionCard(
          gender: _formatGender(currentProfile.gender),
          bodyFat: UnitConverter.formatBodyFat(currentProfile.bodyFat),
          muscleMass: UnitConverter.formatMuscleMass(currentProfile.muscleMass, imperial),
        ),
        SizedBox(height: 24),
        _FitnessActionsCard(
          onEditPhysicalData: _openEditFitnessProfile,
          onAddPhysicalLog: _openAddPhysicalLog,
          onViewProgress: _openFitnessProgress,
        ),
      ],
    );
  }
}

class _FitnessHeaderCard extends StatelessWidget {
  const _FitnessHeaderCard({
    required this.username,
    required this.goal,
    required this.updatedAt,
  });

  final String username;
  final String goal;
  final String updatedAt;

  @override
  Widget build(BuildContext context) {
    final hasGoal = goal != 'Sin configurar';

    return AppCard.elevated(
      borderRadius: 28,
      padding: EdgeInsets.all(26),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.inputBackground,
              border: Border.all(
                color: context.colors.primary,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.fitness_center,
              color: context.colors.primary,
              size: 42,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Datos físicos',
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
            username,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 14,
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: context.colors.inputBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasGoal
                    ? context.colors.primary.withOpacity(0.35)
                    : context.colors.divider.withOpacity(0.4),
                width: 0.8,
              ),
            ),
            child: Text(
              goal,
              style: TextStyle(
                color: hasGoal
                    ? context.colors.primary
                    : context.colors.textMain.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontStyle: hasGoal ? FontStyle.normal : FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Actualizado: $updatedAt',
            style: TextStyle(
              color: context.colors.textMain.withOpacity(0.55),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MainStatsCard extends StatelessWidget {
  const _MainStatsCard({
    required this.weight,
    required this.height,
    required this.age,
  });

  final String weight;
  final String height;
  final String age;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      borderRadius: 24,
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.monitor_weight_outlined,
              label: 'Peso',
              value: weight,
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.height,
              label: 'Altura',
              value: height,
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.cake_outlined,
              label: 'Edad',
              value: age,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == '--';

    return Column(
      children: [
        Icon(
          icon,
          color: context.colors.primary,
          size: 26,
        ),
        SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            color: isEmpty
                ? context.colors.textMain.withOpacity(0.45)
                : context.colors.textMain,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: context.colors.secondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 72,
      color: context.colors.divider.withOpacity(0.7),
      margin: EdgeInsets.symmetric(horizontal: 10),
    );
  }
}

class _BodyCompositionCard extends StatelessWidget {
  const _BodyCompositionCard({
    required this.gender,
    required this.bodyFat,
    required this.muscleMass,
  });

  final String gender;
  final String bodyFat;
  final String muscleMass;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      borderRadius: 24,
      padding: EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DetailBox(
                  icon: Icons.wc,
                  label: 'Género',
                  value: gender,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _DetailBox(
                  icon: Icons.percent,
                  label: 'Grasa',
                  value: bodyFat,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _DetailBox(
            icon: Icons.fitness_center,
            label: 'Masa muscular',
            value: muscleMass,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  const _DetailBox({
    required this.icon,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == '--' || value == 'Sin configurar';

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.inputBorder,
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: context.colors.primary,
            size: 23,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: context.colors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    color: isEmpty
                        ? context.colors.textMain.withOpacity(0.45)
                        : context.colors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FitnessActionsCard extends StatelessWidget {
  const _FitnessActionsCard({
    required this.onEditPhysicalData,
    required this.onAddPhysicalLog,
    required this.onViewProgress,
  });

  final VoidCallback onEditPhysicalData;
  final VoidCallback onAddPhysicalLog;
  final VoidCallback onViewProgress;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      borderRadius: 24,
      padding: EdgeInsets.all(18),
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.edit_outlined,
            title: 'Editar datos físicos',
            subtitle: 'Altura, edad, género y objetivo',
            onTap: onEditPhysicalData,
          ),
          SizedBox(height: 10),
          _ActionTile(
            icon: Icons.add_chart,
            title: 'Añadir registro físico',
            subtitle: 'Registra peso, grasa corporal y masa muscular',
            onTap: onAddPhysicalLog,
          ),
          SizedBox(height: 10),
          _ActionTile(
            icon: Icons.show_chart,
            title: 'Ver estadísticas',
            subtitle: 'Histórico y progreso físico',
            onTap: onViewProgress,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
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
            Icon(
              Icons.chevron_right,
              color: context.colors.secondary,
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.divider.withOpacity(0.4),
          width: 0.7,
        ),
      ),
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
              'Reintentar',
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
