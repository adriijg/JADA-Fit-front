import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';

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
            color: context.colors.tertiary,
            backgroundColor: context.colors.inputBackground,
            borderColor: context.colors.tertiary.withOpacity(0.5),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.homeAICoach,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  AppLocalizations.of(context)!.homeAICoachSubtitle,
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