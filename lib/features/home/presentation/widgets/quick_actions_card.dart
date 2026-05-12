import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SmartQuickActionsCard extends StatelessWidget {
  const SmartQuickActionsCard({
    super.key,
    required this.onScanFood,
    required this.onRegisterMeal,
    required this.onAddPhysicalData,
    required this.onViewWorkout,
    required this.onAskAi,
  });

  final VoidCallback onScanFood;
  final VoidCallback onRegisterMeal;
  final VoidCallback onAddPhysicalData;
  final VoidCallback onViewWorkout;
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.4),
          width: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              'Accesos rápidos',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          QuickActionTile(
            icon: Icons.qr_code_scanner,
            title: 'Escanear alimento',
            subtitle: 'Lee un código de barras y busca el alimento',
            onTap: onScanFood,
          ),
          const SizedBox(height: 10),
          QuickActionTile(
            icon: Icons.restaurant_menu,
            title: 'Registrar comida',
            subtitle: 'Añade una comida al día actual',
            onTap: onRegisterMeal,
          ),
          const SizedBox(height: 10),
          QuickActionTile(
            icon: Icons.add_chart,
            title: 'Añadir datos físicos',
            subtitle: 'Registra peso, grasa corporal y masa muscular',
            onTap: onAddPhysicalData,
          ),
          const SizedBox(height: 10),
          QuickActionTile(
            icon: Icons.calendar_month_outlined,
            title: 'Ver rutina',
            subtitle: 'Consulta tu entrenamiento actual',
            onTap: onViewWorkout,
          ),
          const SizedBox(height: 10),
          QuickActionTile(
            icon: Icons.auto_awesome,
            title: 'Preguntar a la IA',
            subtitle: 'Recibe una recomendación personalizada',
            onTap: onAskAi,
          ),
        ],
      ),
    );
  }
}

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.inputBorder, width: 0.7),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
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
            const Icon(Icons.chevron_right, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}