import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class WorkoutSummaryCard extends StatelessWidget {
  WorkoutSummaryCard({
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
    final l10n = AppLocalizations.of(context)!;
    return SmallDashboardCard(
      icon: Icons.fitness_center,
      title: l10n.homeWorkoutCardTitle,
      value: workoutName ?? l10n.homeNoRoutine,
      subtitle: pendingExercises != null
          ? l10n.homePendingExercises(pendingExercises!)
          : l10n.homeNoPendingExercises,
      onTap: onTap,
    );
  }
}

class PhysicalProgressCard extends StatelessWidget {
  PhysicalProgressCard({
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
    final l10n = AppLocalizations.of(context)!;
    final imperial = context.watch<SettingsProvider>().isImperial;

    final weightStr = currentWeight != null
        ? UnitConverter.formatWeight(currentWeight, imperial)
        : l10n.homeNoProgressData;

    String deltaStr;
    if (weightDelta == null) {
      deltaStr = l10n.homeAddFirstRecord;
    } else {
      deltaStr = l10n.homeWeightChangeSinceStart(
        UnitConverter.formatWeightChange(weightDelta, imperial),
      );
    }

    return SmallDashboardCard(
      icon: Icons.show_chart,
      title: l10n.homeProgressCardTitle,
      value: weightStr,
      subtitle: deltaStr,
      onTap: onTap,
    );
  }
}

class SmallDashboardCard extends StatelessWidget {
  SmallDashboardCard({
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
      padding: EdgeInsets.all(18),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCardIcon(icon: icon, size: 46, borderRadius: 16, iconSize: 24),
          SizedBox(height: 16),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              color: context.colors.textMain.withOpacity(0.62),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}