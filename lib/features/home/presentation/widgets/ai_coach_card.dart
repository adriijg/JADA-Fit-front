import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

class AiCoachCard extends StatelessWidget {
  const AiCoachCard({
    super.key,
    required this.onTap,
    this.message,
  });

  final VoidCallback onTap;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return AppCard.tertiary(
      onTap: onTap,
      borderRadius: 24,
      child: Row(
        children: [
          AppCardIcon(
            icon: Icons.auto_awesome,
            size: 54,
            borderRadius: 18,
            iconSize: 28,
            color: AppColors.tertiary,
            backgroundColor: AppColors.inputBackground,
            borderColor: AppColors.tertiary.withOpacity(0.5),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coach IA',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Toca para recibir una recomendación personalizada.',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.secondary),
        ],
      ),
    );
  }
}