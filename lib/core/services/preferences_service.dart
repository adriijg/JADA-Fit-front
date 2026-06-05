import 'package:flutter/material.dart';

import 'preferences_storage.dart'
    if (dart.library.html) 'preferences_storage_web.dart';

class PreferencesService {
  static const _keyUnits = 'units_imperial';
  static const _keyThemeMode = 'theme_mode';
  static const _keyAiNotifications = 'ai_notifications';
  static const _keyWorkoutReminders = 'workout_reminders';
  static const _keyLanguage = 'language_code';

  static PreferencesService? _instance;
  static PreferencesService get instance => _instance ??= PreferencesService._();
  PreferencesService._();

  final PreferencesStorage _storage = PreferencesStorage();

  Future<void> init() async {
    await _storage.init();
  }

  bool get isImperial => _storage.getBool(_keyUnits) ?? false;
  set isImperial(bool value) => _storage.setBool(_keyUnits, value);

  ThemeMode get themeMode {
    final index = _storage.getInt(_keyThemeMode) ?? 2;
    return ThemeMode.values[
      (index >= 0 && index < ThemeMode.values.length) ? index : 2
    ];
  }
  set themeMode(ThemeMode value) => _storage.setInt(_keyThemeMode, value.index);

  bool get aiNotificationsEnabled => _storage.getBool(_keyAiNotifications) ?? true;
  set aiNotificationsEnabled(bool value) => _storage.setBool(_keyAiNotifications, value);

  bool get workoutRemindersEnabled => _storage.getBool(_keyWorkoutReminders) ?? false;
  set workoutRemindersEnabled(bool value) => _storage.setBool(_keyWorkoutReminders, value);

  String? get languageCode => _storage.getString(_keyLanguage);
  set languageCode(String? value) {
    if (value == null) {
      _storage.remove(_keyLanguage);
    } else {
      _storage.setString(_keyLanguage, value);
    }
  }
}
