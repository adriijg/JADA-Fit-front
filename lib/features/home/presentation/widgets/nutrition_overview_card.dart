import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

class NutritionErrorCard extends StatelessWidget {
  const NutritionErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onTap,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard.error(
      onTap: onTap,
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrición de hoy',
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Resumen de calorías y macros',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 18),
          const Icon(Icons.error_outline, color: AppColors.error, size: 36),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          AppCardButton(
            label: 'Reintentar',
            onTap: onRetry,
          ),
        ],
      ),
    );
  }
}

class NutritionOverviewCard extends StatelessWidget {
  const NutritionOverviewCard({
    super.key,
    required this.caloriesConsumed,
    required this.caloriesGoal,
    required this.caloriesProgress,
    required this.proteinConsumed,
    required this.proteinGoal,
    required this.carbsConsumed,
    required this.carbsGoal,
    required this.fatsConsumed,
    required this.fatsGoal,
    required this.onTap,
  });

  final int caloriesConsumed;
  final int caloriesGoal;
  final double caloriesProgress;

  final int proteinConsumed;
  final int proteinGoal;

  final int carbsConsumed;
  final int carbsGoal;

  final int fatsConsumed;
  final int fatsGoal;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final remainingCalories = caloriesGoal - caloriesConsumed;

    return AppCard.primary(
      onTap: onTap,
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrición de hoy',
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Resumen de calorías y macros',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              CalorieRingChart(
                progress: caloriesProgress,
                consumed: caloriesConsumed,
                goal: caloriesGoal,
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NutritionMetric(
                      label: 'Consumidas',
                      value: '$caloriesConsumed kcal',
                      icon: Icons.local_fire_department,
                    ),
                    const SizedBox(height: 12),
                    NutritionMetric(
                      label: 'Objetivo',
                      value: '$caloriesGoal kcal',
                      icon: Icons.flag_outlined,
                    ),
                    const SizedBox(height: 12),
                    NutritionMetric(
                      label: 'Restantes',
                      value:
                          '${remainingCalories.clamp(0, caloriesGoal)} kcal',
                      icon: Icons.bolt_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          MacroProgressBar(
            label: 'Proteína',
            consumed: proteinConsumed,
            goal: proteinGoal,
            unit: 'g',
          ),
          const SizedBox(height: 14),
          MacroProgressBar(
            label: 'Carbos',
            consumed: carbsConsumed,
            goal: carbsGoal,
            unit: 'g',
          ),
          const SizedBox(height: 14),
          MacroProgressBar(
            label: 'Grasas',
            consumed: fatsConsumed,
            goal: fatsGoal,
            unit: 'g',
          ),
        ],
      ),
    );
  }
}

class CalorieRingChart extends StatelessWidget {
  const CalorieRingChart({
    super.key,
    required this.progress,
    required this.consumed,
    required this.goal,
  });

  final double progress;
  final int consumed;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: 116,
      height: 116,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(116, 116),
            painter: _RingProgressPainter(progress: safeProgress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(safeProgress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$consumed/$goal',
                style: TextStyle(
                  color: AppColors.textMain.withOpacity(0.68),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'kcal',
                style: TextStyle(
                  color: AppColors.textMain.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingProgressPainter extends CustomPainter {
  const _RingProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = AppColors.inputBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class NutritionMetric extends StatelessWidget {
  const NutritionMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 19),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textMain,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class MacroProgressBar extends StatelessWidget {
  const MacroProgressBar({
    super.key,
    required this.label,
    required this.consumed,
    required this.goal,
    required this.unit,
  });

  final String label;
  final int consumed;
  final int goal;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final progress = goal == 0 ? 0.0 : (consumed / goal).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '$consumed / $goal $unit',
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.inputBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}