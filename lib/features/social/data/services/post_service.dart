import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/post.dart';
import '../models/post_comment.dart';

class PostService {
  PostService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  // ── Upload image then create post ─────────────────────────────────────────

  Future<Post> createPost({
    required String imagePath,
    String? caption,
  }) async {
    final token = await _getTokenOrThrow();

    // 1. Upload image first and get the server URL
    final serverImageUrl = await UploadService().uploadImage(imagePath);

    // 2. Create the post with the server URL
    final response = await _client.post(
      Uri.parse(ApiEndpoints.posts),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'imageUrl': serverImageUrl,
        'caption': caption,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  // ── Feed / posts ──────────────────────────────────────────────────────────

  Future<List<Post>> getFeed() async {
    final token = await _getTokenOrThrow();
    final response = await _client.get(
      Uri.parse(ApiEndpoints.postsFeed),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<List<Post>> getExplore() async {
    final token = await _getTokenOrThrow();
    final response = await _client.get(
      Uri.parse(ApiEndpoints.postsExplore),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<List<Post>> getUserPosts(String userId) async {
    final token = await _getTokenOrThrow();
    final response = await _client.get(
      Uri.parse(ApiEndpoints.postsByUser(userId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  // ── Likes ─────────────────────────────────────────────────────────────────

  Future<void> likePost(String postId) async {
    final token = await _getTokenOrThrow();
    final response = await _client.post(
      Uri.parse(ApiEndpoints.postLike(postId)),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(_parseErrorMessage(response.body),
          statusCode: response.statusCode);
    }
  }

  Future<void> unlikePost(String postId) async {
    final token = await _getTokenOrThrow();
    final response = await _client.delete(
      Uri.parse(ApiEndpoints.postLike(postId)),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(_parseErrorMessage(response.body),
          statusCode: response.statusCode);
    }
  }

  // ── Comments ──────────────────────────────────────────────────────────────

  Future<List<PostComment>> getComments(String postId) async {
    final token = await _getTokenOrThrow();
    final response = await _client.get(
      Uri.parse(ApiEndpoints.postComments(postId)),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PostComment.fromJson(json)).toList();
    }

    throw ApiException(_parseErrorMessage(response.body),
        statusCode: response.statusCode);
  }

  Future<PostComment> addComment(String postId, String content) async {
    final token = await _getTokenOrThrow();
    final response = await _client.post(
      Uri.parse(ApiEndpoints.postComments(postId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return PostComment.fromJson(jsonDecode(response.body));
    }

    throw ApiException(_parseErrorMessage(response.body),
        statusCode: response.statusCode);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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
