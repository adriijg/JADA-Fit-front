import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.borderColor,
    this.borderWidth = 0.8,
    this.backgroundColor = AppColors.surface,
    this.boxShadow,
  });

  factory AppCard.primary({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    double borderRadius = 24,
  }) {
    return AppCard(
      key: key,
      onTap: onTap,
      padding: padding,
      borderRadius: borderRadius,
      borderColor: AppColors.primary.withOpacity(0.28),
      backgroundColor: AppColors.surface,
      child: child,
    );
  }

  factory AppCard.tertiary({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(22),
    double borderRadius = 24,
  }) {
    return AppCard(
      key: key,
      onTap: onTap,
      padding: padding,
      borderRadius: borderRadius,
      borderColor: AppColors.tertiary.withOpacity(0.45),
      backgroundColor: AppColors.surface,
      child: child,
    );
  }

  factory AppCard.error({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(22),
    double borderRadius = 24,
  }) {
    return AppCard(
      key: key,
      onTap: onTap,
      padding: padding,
      borderRadius: borderRadius,
      borderColor: AppColors.error.withOpacity(0.5),
      backgroundColor: AppColors.surface,
      child: child,
    );
  }

  factory AppCard.elevated({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    double borderRadius = 24,
    Color borderColor = AppColors.divider,
    double borderOpacity = 0.4,
  }) {
    return AppCard(
      key: key,
      onTap: onTap,
      padding: padding,
      borderRadius: borderRadius,
      borderColor: borderColor.withOpacity(borderOpacity),
      backgroundColor: AppColors.surface,
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
      child: child,
    );
  }

  factory AppCard.input({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
    double borderRadius = 18,
  }) {
    return AppCard(
      key: key,
      onTap: onTap,
      padding: padding,
      borderRadius: borderRadius,
      borderColor: AppColors.inputBorder,
      borderWidth: 0.7,
      backgroundColor: AppColors.inputBackground,
      child: child,
    );
  }

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.divider.withOpacity(0.4),
          width: borderWidth,
        ),
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}

class AppCardIcon extends StatelessWidget {
  const AppCardIcon({
    super.key,
    required this.icon,
    this.size = 46,
    this.iconSize = 24,
    this.borderRadius = 16,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.inputBackground,
    this.borderColor,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final double borderRadius;
  final Color color;
  final Color backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 0.8)
            : null,
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

class AppCardSectionTitle extends StatelessWidget {
  const AppCardSectionTitle(
    this.text, {
    super.key,
    this.trailing,
  });

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

class AppCardDivider extends StatelessWidget {
  const AppCardDivider({super.key, this.height = 18});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height),
      child: const Divider(
        color: AppColors.divider,
        height: 1,
      ),
    );
  }
}

class AppCardRow extends StatelessWidget {
  const AppCardRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconSize = 44,
    this.iconRadius = 16,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final double iconSize;
  final double iconRadius;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppCardIcon(
          icon: icon,
          size: iconSize,
          borderRadius: iconRadius,
          color: iconColor,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AppMacroBadge extends StatelessWidget {
  const AppMacroBadge({
    super.key,
    required this.label,
    required this.value,
    this.highlighted = false,
    this.borderRadius = 14,
    this.fontSize = 13,
  });

  final String label;
  final String value;
  final bool highlighted;
  final double borderRadius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.primary.withOpacity(0.14)
              : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: highlighted
              ? null
              : Border.all(color: AppColors.inputBorder, width: 0.7),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: highlighted ? AppColors.primary : AppColors.textMain,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: highlighted ? AppColors.primary : AppColors.secondary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.text,
    this.highlighted = false,
  });

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withOpacity(0.14)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: highlighted ? AppColors.primary : AppColors.secondary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AppCardButton extends StatelessWidget {
  const AppCardButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = AppColors.background,
    this.borderRadius = 14,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      );
    }

    return SizedBox(width: double.infinity, child: btn);
  }
}

class AppCardOutlinedButton extends StatelessWidget {
  const AppCardOutlinedButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.borderRadius = 14,
    this.color = AppColors.primary,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final double borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final btn = OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.4)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );

    if (icon != null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withOpacity(0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
    }

    return SizedBox(width: double.infinity, child: btn);
  }
}

class AppBottomSheetHandle extends StatelessWidget {
  const AppBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class AppBottomSheetTitle extends StatelessWidget {
  const AppBottomSheetTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class AppBottomSheetOption extends StatelessWidget {
  const AppBottomSheetOption({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder, width: 0.7),
            ),
            child: Row(
              children: [
                AppCardIcon(
                  icon: icon,
                  size: 40,
                  borderRadius: 14,
                  iconSize: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.secondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppBottomSheetSimpleOption extends StatelessWidget {
  const AppBottomSheetSimpleOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder, width: 0.7),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
