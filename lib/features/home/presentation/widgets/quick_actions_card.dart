import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

class SmartQuickActionsCard extends StatelessWidget {
  SmartQuickActionsCard({
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
    return AppCard.elevated(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              'Accesos rápidos',
              style: TextStyle(
                color: context.colors.textMain,
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
          SizedBox(height: 10),
          QuickActionTile(
            icon: Icons.restaurant_menu,
            title: 'Registrar comida',
            subtitle: 'Añade una comida al día actual',
            onTap: onRegisterMeal,
          ),
          SizedBox(height: 10),
          QuickActionTile(
            icon: Icons.add_chart,
            title: 'Añadir datos físicos',
            subtitle: 'Registra peso, grasa corporal y masa muscular',
            onTap: onAddPhysicalData,
          ),
          SizedBox(height: 10),
          QuickActionTile(
            icon: Icons.calendar_month_outlined,
            title: 'Ver rutina',
            subtitle: 'Consulta tu entrenamiento actual',
            onTap: onViewWorkout,
          ),
          SizedBox(height: 10),
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
  QuickActionTile({
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
    return AppCard.input(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 24),
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
          Icon(Icons.chevron_right, color: context.colors.secondary),
        ],
      ),
    );
  }
}