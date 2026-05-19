import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _tokenKey = 'jwt_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static final Map<String, String> _webFallback = {};

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      _webFallback[_tokenKey] = token;
      return;
    }
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      return _webFallback[_tokenKey];
    }
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      _webFallback.remove(_tokenKey);
      return;
    }
    await _storage.delete(key: _tokenKey);
  }
}
