import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/login_response_model.dart';
import '../models/user_account_model.dart';

class AuthService {
  AuthService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<LoginResponseModel> login({
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

      return loginResponse;
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<LoginResponseModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.register),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final loginResponse = LoginResponseModel.fromJson(data);

      await _storageService.saveToken(loginResponse.token);

      return loginResponse;
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<UserAccountModel> getCurrentUser() async {
    final token = await _getTokenOrThrow();

    final response = await _client.get(
      Uri.parse(ApiEndpoints.me),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return UserAccountModel.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<String?> getToken() {
    return _storageService.getToken();
  }

  Future<void> logout() async {
    try {
      final token = await _storageService.getToken();
      if (token != null) {
        await _client.post(
          Uri.parse(ApiEndpoints.logout),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (_) {
    }
    await _storageService.deleteToken();
  }

  Future<void> forgotPassword(String email) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.forgotPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return;
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<String> resetPassword(String token, String newPassword) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.resetPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'newPassword': newPassword}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] as String;
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<String> _getTokenOrThrow() async {
    final token = await _storageService.getToken();

    if (token == null || token.isEmpty) {
      throw ApiException('No hay sesión activa');
    }

    return token;
  }

  String _parseErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] is String) {
          return decoded['message'] as String;
        }

        if (decoded['error'] is String) {
          return decoded['error'] as String;
        }
      }
    } catch (_) {
      // Fall back to raw body
    }

    return body.isNotEmpty ? body : 'Ocurrió un error en el servidor';
  }
}
