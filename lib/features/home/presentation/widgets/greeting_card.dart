import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';

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
            AppLocalizations.of(context)!.homeGreeting,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.homeMainPanel,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}