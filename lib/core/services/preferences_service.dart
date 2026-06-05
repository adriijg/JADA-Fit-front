import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyUnits = 'units_imperial';
  static const _keyThemeMode = 'theme_mode';
  static const _keyAiNotifications = 'ai_notifications';
  static const _keyWorkoutReminders = 'workout_reminders';
  static const _keyLanguage = 'language_code';

  static PreferencesService? _instance;
  static PreferencesService get instance => _instance ??= PreferencesService._();
  PreferencesService._();

  SharedPreferences? _prefs;
  final Map<String, Object?> _webFallback = {};

  Future<void> init() async {
    if (kIsWeb) {
      debugPrint('PreferencesService: using web fallback storage.');
      return;
    }

    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (error, stack) {
      debugPrint('PreferencesService.init failed: $error');
      debugPrint('$stack');
      _prefs = null;
    }
  }

  bool _getBool(String key, bool defaultValue) {
    if (_prefs != null) {
      return _prefs!.getBool(key) ?? defaultValue;
    }
    return _webFallback[key] as bool? ?? defaultValue;
  }

  void _setBool(String key, bool value) {
    if (_prefs != null) {
      _prefs!.setBool(key, value);
      return;
    }
    _webFallback[key] = value;
  }

  int _getInt(String key, int defaultValue) {
    if (_prefs != null) {
      return _prefs!.getInt(key) ?? defaultValue;
    }
    return _webFallback[key] as int? ?? defaultValue;
  }

  void _setInt(String key, int value) {
    if (_prefs != null) {
      _prefs!.setInt(key, value);
      return;
    }
    _webFallback[key] = value;
  }

  String? _getString(String key) {
    if (_prefs != null) {
      return _prefs!.getString(key);
    }
    return _webFallback[key] as String?;
  }

  void _setString(String key, String value) {
    if (_prefs != null) {
      _prefs!.setString(key, value);
      return;
    }
    _webFallback[key] = value;
  }

  void _remove(String key) {
    if (_prefs != null) {
      _prefs!.remove(key);
      return;
    }
    _webFallback.remove(key);
  }

  bool get isImperial => _getBool(_keyUnits, false);
  set isImperial(bool value) => _setBool(_keyUnits, value);

  ThemeMode get themeMode {
    final index = _getInt(_keyThemeMode, 2);
    return ThemeMode.values[
      (index >= 0 && index < ThemeMode.values.length) ? index : 2
    ];
  }
  set themeMode(ThemeMode value) => _setInt(_keyThemeMode, value.index);

  bool get aiNotificationsEnabled => _getBool(_keyAiNotifications, true);
  set aiNotificationsEnabled(bool value) => _setBool(_keyAiNotifications, value);

  bool get workoutRemindersEnabled => _getBool(_keyWorkoutReminders, false);
  set workoutRemindersEnabled(bool value) => _setBool(_keyWorkoutReminders, value);

  String? get languageCode => _getString(_keyLanguage);
  set languageCode(String? value) {
    if (value == null) {
      _remove(_keyLanguage);
    } else {
      _setString(_keyLanguage, value);
    }
  }
}
