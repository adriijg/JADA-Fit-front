import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Web: mismo origen (/api), el backend sirve frontend + API.
  /// Android emulador: 10.0.2.2 mapea a localhost de la máquina host.
  static String get baseUrl {
    if (kIsWeb) return '/api';
    return 'http://10.0.2.2:8080/api';
  }
}
