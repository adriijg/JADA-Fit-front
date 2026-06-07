import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef _Storage = FlutterSecureStorage;

class SecureStorageService {
  static const String _tokenKey = 'jwt_token';

  final _Storage? _storage;
  static final Map<String, String> _webFallback = {};

  SecureStorageService() : _storage = kIsWeb ? null : const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      _webFallback[_tokenKey] = token;
      return;
    }
    await _storage!.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      return _webFallback[_tokenKey];
    }
    return _storage!.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      _webFallback.remove(_tokenKey);
      return;
    }
    await _storage!.delete(key: _tokenKey);
  }
  Future<String?> read({required String key}) async {
    if (kIsWeb) {
      return _webFallback[key];
    }
    return _storage!.read(key: key);
  }

  Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      _webFallback[key] = value;
      return;
    }
    await _storage!.write(key: key, value: value);
  }

  Future<void> delete({required String key}) async {
    if (kIsWeb) {
      _webFallback.remove(key);
      return;
    }
    await _storage!.delete(key: key);
  }}
