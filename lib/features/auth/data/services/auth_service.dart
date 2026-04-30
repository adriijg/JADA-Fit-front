import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/login_response_model.dart';

class AuthService {
  AuthService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.login),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final loginResponse = LoginResponseModel.fromJson(data);

      await _storageService.saveToken(loginResponse.token);
      return;
    }

    throw ApiException(
      'Login fallido',
      statusCode: response.statusCode,
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.register),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw ApiException(
      'Registro fallido',
      statusCode: response.statusCode,
    );
  }

  Future<String?> getToken() {
    return _storageService.getToken();
  }

  Future<void> logout() {
    return _storageService.deleteToken();
  }
}