import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.inputBackground,
          shape: BoxShape.circle,
          border: Border.all(
            color: context.colors.divider.withOpacity(0.7),
            width: 1.2,
          ),

        ),
        child: FaIcon(
          icon,
          color: color,
          size: 26,
        ),
      ),
    );
  }
}
