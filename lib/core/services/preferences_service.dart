import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyUnits = 'units_imperial';
  static const _keyThemeMode = 'theme_mode';
  static const _keyAiNotifications = 'ai_notifications';
  static const _keyWorkoutReminders = 'workout_reminders';

  static PreferencesService? _instance;
  static PreferencesService get instance => _instance ??= PreferencesService._();
  PreferencesService._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isImperial => _prefs.getBool(_keyUnits) ?? false;
  set isImperial(bool value) => _prefs.setBool(_keyUnits, value);

  ThemeMode get themeMode {
    final index = _prefs.getInt(_keyThemeMode) ?? 2;
    return ThemeMode.values[index];
  }
  set themeMode(ThemeMode value) => _prefs.setInt(_keyThemeMode, value.index);

  bool get aiNotificationsEnabled => _prefs.getBool(_keyAiNotifications) ?? true;
  set aiNotificationsEnabled(bool value) => _prefs.setBool(_keyAiNotifications, value);

  bool get workoutRemindersEnabled => _prefs.getBool(_keyWorkoutReminders) ?? false;
  set workoutRemindersEnabled(bool value) => _prefs.setBool(_keyWorkoutReminders, value);
}
