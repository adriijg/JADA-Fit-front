import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/network/auth_http_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../models/story.dart';

class StoryService {
  StoryService({
    http.Client? client,
  }) : _client = client ?? AuthHttpClient();

  final http.Client _client;

  Future<Story> createStory({required String imageUrl}) async {
    final serverImageUrl = ImageUrlResolver.isServerImageUrl(imageUrl)
        ? imageUrl
        : await UploadService().uploadImage(imageUrl);

    final response = await _client.post(
      Uri.parse(ApiEndpoints.stories),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'imageUrl': serverImageUrl,
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
    final response = await _client.get(
      Uri.parse(ApiEndpoints.storiesFeed),
      headers: {
        'Content-Type': 'application/json',
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

  Future<void> deleteStory(String storyId) async {
    final response = await _client.delete(
      Uri.parse(ApiEndpoints.storyDelete(storyId)),
      headers: {},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(_parseErrorMessage(response.body),
          statusCode: response.statusCode);
    }
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
