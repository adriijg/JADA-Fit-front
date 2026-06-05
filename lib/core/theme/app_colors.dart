import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFD1FF00);
  static const Color secondary = Color(0xFF00E5FF);
  static const Color tertiary = Color(0xFF8B6BFF);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color error = Color(0xFFEA4335);
  static const Color success = Color(0xFF2ECC71);

  static const Color background = Color(0xFF02030F);
  static const Color surface = Color(0xFF161D25);
  static const Color inputBackground = Color(0xFF062329);
  static const Color inputBorder = Color(0xFF0B3A45);
  static const Color textMain = Color(0xFFE8E8E8);
  static const Color divider = Color(0xFF2A3A45);

  static AppPalette of(BuildContext context) {
    return AppPaletteScope.of(context);
  }

  static const AppPalette darkPalette = AppPalette(
    background: Color(0xFF02030F),
    surface: Color(0xFF161D25),
    inputBackground: Color(0xFF062329),
    inputBorder: Color(0xFF0B3A45),
    textMain: Color(0xFFE8E8E8),
    divider: Color(0xFF2A3A45),
    primary: Color(0xFFD1FF00),
    secondary: Color(0xFF00E5FF),
    tertiary: Color(0xFF8B6BFF),
  );

  static const AppPalette lightPalette = AppPalette(
    background: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    inputBackground: Color(0xFFEEEEEE),
    inputBorder: Color(0xFFD0D0D0),
    textMain: Color(0xFF000000),
    divider: Color(0xFFE0E0E0),
    primary: Color(0xFFA0C000),
    secondary: Color(0xFF009AC0),
    tertiary: Color(0xFF6B4FCC),
  );
}

class AppPalette {
  final Color background;
  final Color surface;
  final Color inputBackground;
  final Color inputBorder;
  final Color textMain;
  final Color divider;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.inputBackground,
    required this.inputBorder,
    required this.textMain,
    required this.divider,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });
}

class AppPaletteScope extends InheritedWidget {
  final AppPalette palette;

  const AppPaletteScope({
    super.key,
    required this.palette,
    required super.child,
  });

  static AppPalette of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppPaletteScope>();
    assert(scope != null, 'No AppPaletteScope found in context');
    return scope!.palette;
  }

  @override
  bool updateShouldNotify(AppPaletteScope oldWidget) => palette != oldWidget.palette;
}

extension AppColorsContext on BuildContext {
  AppPalette get colors => AppPaletteScope.of(this);
}
