import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AiCoachCard extends StatelessWidget {
  const AiCoachCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.tertiary.withOpacity(0.45),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.tertiary.withOpacity(0.5),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.tertiary,
                size: 28,
              ),
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
                    'Vas bajo de proteína. Añade una comida rica en proteína para acercarte a tu objetivo.',
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
      ),
    );
  }
}