import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';

class SocialSummaryCard extends StatelessWidget {
  const SocialSummaryCard({
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
      subtitle = AppLocalizations.of(context)!.homeConnectWithOthers;
    } else {
      final parts = <String>[];
      if (activeChallenges != null) {
        parts.add('$activeChallenges reto${activeChallenges == 1 ? '' : 's'} activo${activeChallenges == 1 ? '' : 's'}');
      }
      if (pendingRequests != null && pendingRequests! > 0) {
        parts.add('$pendingRequests solicitud${pendingRequests == 1 ? '' : 'es'} pendiente${pendingRequests == 1 ? '' : 's'}');
      }
      subtitle = parts.isNotEmpty ? parts.join(' · ') : AppLocalizations.of(context)!.homeNoRecentActivity;
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
                  AppLocalizations.of(context)!.homeSocialActivity,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.colors.secondary,
                    fontSize: 12,
                    height: 1.4,
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