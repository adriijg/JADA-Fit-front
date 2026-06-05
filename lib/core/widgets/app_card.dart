import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum _CardStyle { normal, primary, tertiary, error, elevated, input }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.borderColor,
    this.borderWidth = 0.8,
    this.backgroundColor,
    this.boxShadow,
    this.cardStyle = _CardStyle.normal,
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
      cardStyle: _CardStyle.primary,
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
      cardStyle: _CardStyle.tertiary,
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
      cardStyle: _CardStyle.error,
      child: child,
    );
  }

  factory AppCard.elevated({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    double borderRadius = 24,
    Color? borderColor,
    double borderOpacity = 0.4,
  }) {
    return AppCard(
      key: key,
      onTap: onTap,
      padding: padding,
      borderRadius: borderRadius,
      borderColor: borderColor != null ? borderColor.withOpacity(borderOpacity) : null,
      cardStyle: _CardStyle.elevated,
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
      borderWidth: 0.7,
      cardStyle: _CardStyle.input,
      child: child,
    );
  }

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final _CardStyle cardStyle;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBorder;
    switch (cardStyle) {
      case _CardStyle.primary:
        resolvedBorder = borderColor ?? context.colors.primary.withOpacity(0.28);
        break;
      case _CardStyle.tertiary:
        resolvedBorder = borderColor ?? context.colors.tertiary.withOpacity(0.45);
        break;
      case _CardStyle.error:
        resolvedBorder = borderColor ?? AppColors.error.withOpacity(0.5);
        break;
      case _CardStyle.elevated:
        resolvedBorder = borderColor ?? context.colors.divider.withOpacity(0.4);
        break;
      case _CardStyle.input:
        resolvedBorder = borderColor ?? context.colors.inputBorder;
        break;
      case _CardStyle.normal:
        resolvedBorder = borderColor ?? context.colors.divider.withOpacity(0.4);
        break;
    }

    final resolvedShadow = boxShadow ?? (cardStyle == _CardStyle.elevated
        ? [BoxShadow(
            color: context.colors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 6),
          )]
        : null);

    final resolvedBg = backgroundColor ?? (cardStyle == _CardStyle.input
        ? context.colors.inputBackground
        : Theme.of(context).cardColor);

    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: resolvedBorder,
          width: borderWidth,
        ),
        boxShadow: resolvedShadow,
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
  AppCardIcon({
    super.key,
    required this.icon,
    this.size = 46,
    this.iconSize = 24,
    this.borderRadius = 16,
    this.color,
    this.backgroundColor,
    this.borderColor,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final double borderRadius;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.inputBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 0.8)
            : null,
      ),
      child: Icon(icon, color: color ?? context.colors.primary, size: iconSize),
    );
  }
}

class AppCardSectionTitle extends StatelessWidget {
  AppCardSectionTitle(
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
          style: TextStyle(
            color: context.colors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        if (trailing != null) ...[
          Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

class AppCardDivider extends StatelessWidget {
  AppCardDivider({super.key, this.height = 18});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height),
      child: Divider(
        color: context.colors.divider,
        height: 1,
      ),
    );
  }
}

class AppCardRow extends StatelessWidget {
  AppCardRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconSize = 44,
    this.iconRadius = 16,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final double iconSize;
  final double iconRadius;
  final Color? iconColor;

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
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  color: context.colors.textMain,
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
  AppMacroBadge({
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
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: highlighted
              ? context.colors.primary.withOpacity(0.14)
              : context.colors.inputBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: highlighted
              ? null
              : Border.all(color: context.colors.inputBorder, width: 0.7),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: highlighted ? context.colors.primary : context.colors.textMain,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: highlighted ? context.colors.primary : context.colors.secondary,
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
  AppPill({
    super.key,
    required this.text,
    this.highlighted = false,
  });

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlighted
            ? context.colors.primary.withOpacity(0.14)
            : context.colors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: highlighted ? context.colors.primary : context.colors.secondary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AppCardButton extends StatelessWidget {
  AppCardButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 14,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? context.colors.primary;
    final fg = foregroundColor ?? context.colors.background;
    final btn = ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      );
    }

    return SizedBox(width: double.infinity, child: btn);
  }
}

class AppCardOutlinedButton extends StatelessWidget {
  AppCardOutlinedButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.borderRadius = 14,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final double borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final clr = color ?? context.colors.primary;
    final btn = OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: clr,
        side: BorderSide(color: clr.withOpacity(0.4)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w800)),
    );

    if (icon != null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: clr,
            side: BorderSide(color: clr.withOpacity(0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
    }

    return SizedBox(width: double.infinity, child: btn);
  }
}

class AppBottomSheetHandle extends StatelessWidget {
  AppBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.colors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class AppBottomSheetTitle extends StatelessWidget {
  AppBottomSheetTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          color: context.colors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class AppBottomSheetOption extends StatelessWidget {
  AppBottomSheetOption({
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
      padding: EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.inputBorder, width: 0.7),
            ),
            child: Row(
              children: [
                AppCardIcon(
                  icon: icon,
                  size: 40,
                  borderRadius: 14,
                  iconSize: 22,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: context.colors.textMain,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: context.colors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.colors.secondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppBottomSheetSimpleOption extends StatelessWidget {
  AppBottomSheetSimpleOption({
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
      padding: EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.inputBorder, width: 0.7),
            ),
            child: Row(
              children: [
                Icon(icon, color: context.colors.primary, size: 22),
                SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: context.colors.textMain,
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
