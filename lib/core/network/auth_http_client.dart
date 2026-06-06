import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_storage_service.dart';

class AuthHttpClient extends http.BaseClient {
  final http.Client _inner;
  final SecureStorageService _storageService;
  static VoidCallback? onUnauthorized;

  AuthHttpClient({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _inner = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      await _storageService.deleteToken();
      onUnauthorized?.call();
    }

    return response;
  }

  @override
  void close() => _inner.close();
}
