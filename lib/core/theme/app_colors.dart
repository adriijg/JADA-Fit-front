import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand / semantic colors (universal, always the same)
  static const Color primary = const Color(0xFFD1FF00);
  static const Color secondary = const Color(0xFF00E5FF);
  static const Color tertiary = const Color(0xFF8B6BFF);
  static const Color googleRed = const Color(0xFFEA4335);
  static const Color error = const Color(0xFFEA4335);
  static const Color success = const Color(0xFF2ECC71);

  // Internal brightness tracking — updated by of(context) so getters are adaptive
  static Brightness _brightness = Brightness.dark;

  // ── Brightness-aware getters ──────────────────────────────────────
  static Color get background =>
      _brightness == Brightness.light
          ? const Color(0xFFF5F5F5)
          : const Color(0xFF02030F);

  static Color get surface =>
      _brightness == Brightness.light ? Colors.white : const Color(0xFF161D25);

  static Color get inputBackground =>
      _brightness == Brightness.light
          ? const Color(0xFFF0F0F0)
          : const Color(0xFF062329);

  static Color get inputBorder =>
      _brightness == Brightness.light
          ? const Color(0xFFDDDDDD)
          : const Color(0xFF0B3A45);

  static Color get textMain =>
      _brightness == Brightness.light
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFE8E8E8);

  static Color get divider =>
      _brightness == Brightness.light
          ? const Color(0xFFE0E0E0)
          : const Color(0xFF2A3A45);

  /// Returns the full adaptive palette.  Also updates the internal
  /// brightness flag so the static getters above return the correct colour
  /// for the current theme — even when called from declarations like
  /// `TextStyle(color: AppColors.textMain)`.
  static _Palette of(BuildContext context) {
    _brightness = Theme.of(context).brightness;
    return _brightness == Brightness.light ? _lightPalette : _darkPalette;
  }

  static const _Palette _darkPalette = _Palette(
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

  static const _Palette _lightPalette = _Palette(
    background: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    inputBackground: Color(0xFFF0F0F0),
    inputBorder: Color(0xFFDDDDDD),
    textMain: Color(0xFF1A1A1A),
    divider: Color(0xFFE0E0E0),
    primary: Color(0xFF7A9F00),
    secondary: Color(0xFF008397),
    tertiary: Color(0xFF6B4FCC),
  );
}

class _Palette {
  final Color background;
  final Color surface;
  final Color inputBackground;
  final Color inputBorder;
  final Color textMain;
  final Color divider;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  const _Palette({
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
