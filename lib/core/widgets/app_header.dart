import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.onProfileTap,
  });

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(
            bottom: BorderSide(color: context.colors.divider, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.appName,
              style: TextStyle(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1.4,
              ),
            ),
            IconButton(
              onPressed: onProfileTap,
              icon: Icon(
                Icons.person,
                color: context.colors.textMain,
              ),
              tooltip: AppLocalizations.of(context)!.profileTitle,
            ),
          ],
        ),
      ),
    );
  }
}
