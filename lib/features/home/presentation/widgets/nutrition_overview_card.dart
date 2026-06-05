import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

class NutritionErrorCard extends StatelessWidget {
  NutritionErrorCard({
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
      padding: EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrición de hoy',
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Resumen de calorías y macros',
                      style: TextStyle(
                        color: context.colors.secondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.colors.secondary),
            ],
          ),
          SizedBox(height: 18),
          Icon(Icons.error_outline, color: AppColors.error, size: 36),
          SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14),
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
  NutritionOverviewCard({
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
      padding: EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrición de hoy',
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Resumen de calorías y macros',
                      style: TextStyle(
                        color: context.colors.secondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.colors.secondary),
            ],
          ),
          SizedBox(height: 22),
          Row(
            children: [
              CalorieRingChart(
                progress: caloriesProgress,
                consumed: caloriesConsumed,
                goal: caloriesGoal,
              ),
              SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NutritionMetric(
                      label: 'Consumidas',
                      value: '$caloriesConsumed kcal',
                      icon: Icons.local_fire_department,
                    ),
                    SizedBox(height: 12),
                    NutritionMetric(
                      label: 'Objetivo',
                      value: '$caloriesGoal kcal',
                      icon: Icons.flag_outlined,
                    ),
                    SizedBox(height: 12),
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
          SizedBox(height: 24),
          MacroProgressBar(
            label: 'Proteína',
            consumed: proteinConsumed,
            goal: proteinGoal,
            unit: 'g',
          ),
          SizedBox(height: 14),
          MacroProgressBar(
            label: 'Carbos',
            consumed: carbsConsumed,
            goal: carbsGoal,
            unit: 'g',
          ),
          SizedBox(height: 14),
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
  CalorieRingChart({
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
            size: Size(116, 116),
            painter: _RingProgressPainter(
              progress: safeProgress,
              backgroundColor: context.colors.inputBorder,
              progressColor: context.colors.primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(safeProgress * 100).round()}%',
                style: TextStyle(
                  color: context.colors.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '$consumed/$goal',
                style: TextStyle(
                  color: context.colors.textMain.withOpacity(0.68),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'kcal',
                style: TextStyle(
                  color: context.colors.textMain.withOpacity(0.5),
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
  const _RingProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
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
    return oldDelegate.progress != progress
        || oldDelegate.backgroundColor != backgroundColor
        || oldDelegate.progressColor != progressColor;
  }
}

class NutritionMetric extends StatelessWidget {
  NutritionMetric({
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
        Icon(icon, color: context.colors.primary, size: 19),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: context.colors.textMain,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class MacroProgressBar extends StatelessWidget {
  MacroProgressBar({
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
              style: TextStyle(
                color: context.colors.textMain,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Spacer(),
            Text(
              '$consumed / $goal $unit',
              style: TextStyle(
                color: context.colors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: context.colors.inputBorder,
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
          ),
        ),
      ],
    );
  }
}