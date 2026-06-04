import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  AppHeader({
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
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1.4,
              ),
            ),
            IconButton(
              onPressed: onProfileTap,
              icon: Icon(
                Icons.person,
                color: AppColors.textMain,
              ),
              tooltip: AppStrings.profileTitle,
            ),
          ],
        ),
      ),
    );
  }
}
