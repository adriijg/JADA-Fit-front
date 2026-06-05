import 'dart:html';

class PreferencesStorage {
  Future<void> init() async {}

  bool? getBool(String key) {
    final value = window.localStorage[key];
    if (value == null) return null;
    return value == 'true';
  }

  Future<void> setBool(String key, bool value) async {
    window.localStorage[key] = value.toString();
  }

  int? getInt(String key) {
    final value = window.localStorage[key];
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> setInt(String key, int value) async {
    window.localStorage[key] = value.toString();
  }

  String? getString(String key) => window.localStorage[key];

  Future<void> setString(String key, String value) async {
    window.localStorage[key] = value;
  }

  Future<void> remove(String key) async {
    window.localStorage.remove(key);
  }
}
