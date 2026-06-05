import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final palette = AppColors.darkPalette;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.background,
      cardColor: palette.surface,
      dividerColor: palette.divider,
      colorScheme: ColorScheme.dark(
        primary: palette.primary,
        secondary: palette.secondary,
        surface: palette.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.textMain,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: TextStyle(
          color: palette.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        elevation: 16,
      ),
    );
  }

  static ThemeData get lightTheme {
    final palette = AppColors.lightPalette;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: palette.background,
      cardColor: palette.surface,
      dividerColor: palette.divider,
      colorScheme: ColorScheme.light(
        primary: palette.primary,
        secondary: palette.secondary,
        surface: palette.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.textMain,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: TextStyle(
          color: palette.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        elevation: 16,
      ),
    );
  }
}
