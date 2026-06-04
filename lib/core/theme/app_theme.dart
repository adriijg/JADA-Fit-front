import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7A9F00),
        secondary: Color(0xFF008397),
        surface: Colors.white,
      ),
      snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(
          color: Color(0xFF7A9F00),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
