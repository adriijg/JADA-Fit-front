import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Override the API base URL at build time for real devices, staging, or
  /// custom local environments.
  ///
  /// Example:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.0.100:8080/api
  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Web: mismo origen (/api), el backend sirve frontend + API.
  /// Android emulador: 10.0.2.2 mapea a localhost de la máquina host.
  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }

    if (kIsWeb) return '/api';
    return 'http://10.0.2.2:8080/api';
  }
}
