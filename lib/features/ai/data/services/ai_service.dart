import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/chat_message_model.dart';

class AiService {
  AiService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<String> chat(
    String message,
    List<ChatMessageModel> history,
  ) async {
    final token = await _storageService.getToken();

    final response = await _client.post(
      Uri.parse(ApiEndpoints.aiChat),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'message': message,
        'history': history.map((m) => m.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return response.body;
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  String _parseErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message'] as String? ??
            decoded['error'] as String? ??
            'Error en el servidor';
      }
    } catch (_) {}
    return 'Error en el servidor';
  }
}
