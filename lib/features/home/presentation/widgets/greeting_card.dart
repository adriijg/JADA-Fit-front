import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

class GreetingCard extends StatelessWidget {
  GreetingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard.primary(
      borderRadius: 28,
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola 👋',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Este es tu panel principal. Aquí tendrás el resumen de nutrición, entrenamiento, progreso físico y recomendaciones inteligentes.',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}