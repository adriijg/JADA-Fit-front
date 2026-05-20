class ApiConfig {
  // Emulador Android (default)
  // Para web, serve_web.bat lo sobreescribe con --dart-define=BASE_URL=http://IP:8080/api
  static const String baseUrl = String.fromEnvironment('BASE_URL',
      defaultValue: 'http://10.0.2.2:8080/api');
}
