import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

class SocialSummaryCard extends StatelessWidget {
  SocialSummaryCard({
    super.key,
    required this.onTap,
    this.activeChallenges,
    this.pendingRequests,
  });

  final VoidCallback onTap;
  final int? activeChallenges;
  final int? pendingRequests;

  @override
  Widget build(BuildContext context) {
    String subtitle;
    if (activeChallenges == null && pendingRequests == null) {
      subtitle = 'Conéctate con otros usuarios';
    } else {
      final parts = <String>[];
      if (activeChallenges != null) {
        parts.add('$activeChallenges reto${activeChallenges == 1 ? '' : 's'} activo${activeChallenges == 1 ? '' : 's'}');
      }
      if (pendingRequests != null && pendingRequests! > 0) {
        parts.add('$pendingRequests solicitud${pendingRequests == 1 ? '' : 'es'} pendiente${pendingRequests == 1 ? '' : 's'}');
      }
      subtitle = parts.isNotEmpty ? parts.join(' · ') : 'Sin actividad reciente';
    }

    return AppCard.elevated(
      onTap: onTap,
      borderRadius: 24,
      child: Row(
        children: [
          AppCardIcon(
            icon: Icons.people_outline,
            size: 52,
            borderRadius: 18,
            iconSize: 27,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actividad social',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.secondary),
        ],
      ),
    );
  }
}