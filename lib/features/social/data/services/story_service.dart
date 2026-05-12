import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/story.dart';

class StoryService {
  StoryService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<Story> createStory({required String imageUrl}) async {
    final token = await _getTokenOrThrow();
    final response = await _client.post(
      Uri.parse(ApiEndpoints.stories),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Story.fromJson(jsonDecode(response.body));
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<List<Story>> getFeedStories() async {
    final token = await _getTokenOrThrow();
    final response = await _client.get(
      Uri.parse(ApiEndpoints.storiesFeed),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Story.fromJson(json)).toList();
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
