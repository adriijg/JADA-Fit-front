import 'package:flutter/material.dart';
import '../../../../core/services/preferences_service.dart';

class SettingsProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  SettingsProvider(this._prefs);

  bool get isImperial => _prefs.isImperial;
  ThemeMode get themeMode => _prefs.themeMode;
  bool get aiNotificationsEnabled => _prefs.aiNotificationsEnabled;
  bool get workoutRemindersEnabled => _prefs.workoutRemindersEnabled;

  void setImperial(bool value) {
    _prefs.isImperial = value;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.themeMode = mode;
    notifyListeners();
  }

  void setAiNotifications(bool value) {
    _prefs.aiNotificationsEnabled = value;
    notifyListeners();
  }

  void setWorkoutReminders(bool value) {
    _prefs.workoutRemindersEnabled = value;
    notifyListeners();
  }

  String weightSuffix() => isImperial ? 'lbs' : 'kg';
  String heightSuffix() => isImperial ? 'ft' : 'cm';
}
