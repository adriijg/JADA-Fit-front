import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({
    super.key,
    required this.onTap,
    this.workoutName,
    this.pendingExercises,
  });

  final VoidCallback onTap;
  final String? workoutName;
  final int? pendingExercises;

  @override
  Widget build(BuildContext context) {
    return SmallDashboardCard(
      icon: Icons.fitness_center,
      title: 'Workout',
      value: workoutName ?? 'Sin rutina',
      subtitle: pendingExercises != null
          ? '$pendingExercises ejercicio${pendingExercises == 1 ? '' : 's'} pendiente${pendingExercises == 1 ? '' : 's'}'
          : 'Sin ejercicios pendientes',
      onTap: onTap,
    );
  }
}

class PhysicalProgressCard extends StatelessWidget {
  const PhysicalProgressCard({
    super.key,
    required this.onTap,
    this.currentWeight,
    this.weightDelta,
  });

  final VoidCallback onTap;
  final double? currentWeight;
  final double? weightDelta;

  @override
  Widget build(BuildContext context) {
    final imperial = context.watch<SettingsProvider>().isImperial;

    final weightStr = currentWeight != null
        ? UnitConverter.formatWeight(currentWeight, imperial)
        : 'Sin datos';

    String deltaStr;
    if (weightDelta == null) {
      deltaStr = 'A\u00f1ade tu primer registro';
    } else {
      deltaStr = '${UnitConverter.formatWeightChange(weightDelta, imperial)} desde inicio';
    }

    return SmallDashboardCard(
      icon: Icons.show_chart,
      title: 'Progreso',
      value: weightStr,
      subtitle: deltaStr,
      onTap: onTap,
    );
  }
}

class SmallDashboardCard extends StatelessWidget {
  const SmallDashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCardIcon(icon: icon, size: 46, borderRadius: 16, iconSize: 24),
          const SizedBox(height: 16),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textMain.withOpacity(0.62),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}