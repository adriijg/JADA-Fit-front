import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/fitness_profile_model.dart';
import '../../data/services/fitness_profile_service.dart';
import 'add_physical_log_screen.dart';
import 'edit_fitness_profile_screen.dart';
import 'fitness_progress_screen.dart';

class FitnessProfileScreen extends StatefulWidget {
  const FitnessProfileScreen({super.key});

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
        builder: (_) => const FitnessProgressScreen(),
      ),
    );

    if (mounted) {
      await _loadFitnessProfile();
    }
  }

  String _formatDouble(double? value, String unit) {
    if (value == null) return '--';

    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textMain,
        ),
        title: const Text(
          'Perfil físico',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFitnessProfile,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
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
      return const SizedBox(
        height: 500,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
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

    return Column(
      children: [
        _FitnessHeaderCard(
          username: currentProfile.username,
          goal: _formatGoal(currentProfile.goal),
          updatedAt: _formatUpdatedAt(currentProfile.updatedAt),
        ),
        const SizedBox(height: 24),
        _MainStatsCard(
          weight: _formatDouble(currentProfile.weight, 'kg'),
          height: _formatInt(currentProfile.height, 'cm'),
          age: _formatInt(currentProfile.age, 'años'),
        ),
        const SizedBox(height: 18),
        _BodyCompositionCard(
          gender: _formatGender(currentProfile.gender),
          bodyFat: _formatDouble(currentProfile.bodyFat, '%'),
          muscleMass: _formatDouble(currentProfile.muscleMass, 'kg'),
        ),
        const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(26),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.inputBackground,
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.primary,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Datos físicos',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            username,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasGoal
                    ? AppColors.primary.withOpacity(0.35)
                    : AppColors.divider.withOpacity(0.4),
                width: 0.8,
              ),
            ),
            child: Text(
              goal,
              style: TextStyle(
                color: hasGoal
                    ? AppColors.primary
                    : AppColors.textMain.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontStyle: hasGoal ? FontStyle.normal : FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Actualizado: $updatedAt',
            style: TextStyle(
              color: AppColors.textMain.withOpacity(0.55),
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
      padding: const EdgeInsets.all(20),
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
          color: AppColors.primary,
          size: 26,
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            color: isEmpty
                ? AppColors.textMain.withOpacity(0.45)
                : AppColors.textMain,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.secondary,
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
      color: AppColors.divider.withOpacity(0.7),
      margin: const EdgeInsets.symmetric(horizontal: 10),
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
      padding: const EdgeInsets.all(22),
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
              const SizedBox(width: 12),
              Expanded(
                child: _DetailBox(
                  icon: Icons.percent,
                  label: 'Grasa',
                  value: bodyFat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    color: isEmpty
                        ? AppColors.textMain.withOpacity(0.45)
                        : AppColors.textMain,
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
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.edit_outlined,
            title: 'Editar datos físicos',
            subtitle: 'Altura, edad, género y objetivo',
            onTap: onEditPhysicalData,
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.add_chart,
            title: 'Añadir registro físico',
            subtitle: 'Registra peso, grasa corporal y masa muscular',
            onTap: onAddPhysicalLog,
          ),
          const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      child: Row(
        children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.secondary,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.4),
          width: 0.7,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 42,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
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
