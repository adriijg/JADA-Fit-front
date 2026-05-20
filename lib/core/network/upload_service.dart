import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import 'api_exception.dart';
import '../storage/secure_storage_service.dart';

class UploadService {
  UploadService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<String> uploadImage(String filePath) async {
    final token = await _getTokenOrThrow();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiEndpoints.uploadImage),
    );

    Uint8List bytes;
    final filename = filePath.split('/').last;

    if (kIsWeb) {
      final fileResponse = await _client.get(Uri.parse(filePath));
      bytes = fileResponse.bodyBytes;
    } else {
      bytes = await File(filePath).readAsBytes();
    }

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['url'] as String;
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
        if (decoded['message'] is String) return decoded['message'] as String;
        if (decoded['error'] is String) return decoded['error'] as String;
      }
    } catch (_) {}
    return body.isNotEmpty ? body : 'Ocurrió un error inesperado';
  }
}
