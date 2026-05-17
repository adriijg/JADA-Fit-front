import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_profile.dart';
import '../models/user_summary.dart';

class SocialService {
  SocialService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<void> followUser(String userId) async {
    final token = await _getTokenOrThrow();
    final response = await _client.post(
      Uri.parse('${ApiEndpoints.follow}/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(
        _parseErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> unfollowUser(String userId) async {
    final token = await _getTokenOrThrow();
    final response = await _client.delete(
      Uri.parse('${ApiEndpoints.unfollow}/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(
        _parseErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<UserSummary>> getFollowers(String userId) async {
    final token = await _getTokenOrThrow();
    final response = await _client.get(
      Uri.parse('${ApiEndpoints.social}/$userId/followers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserSummary.fromJson(json)).toList();
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<List<UserSummary>> getFollowing(String userId) async {
    final token = await _getTokenOrThrow();
    final response = await _client.get(
      Uri.parse('${ApiEndpoints.social}/$userId/following'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserSummary.fromJson(json)).toList();
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<List<UserSummary>> searchUsers(String query) async {
    final token = await _getTokenOrThrow();
    final response = await _client.get(
      Uri.parse('${ApiEndpoints.social}/users/search?q=$query'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserSummary.fromJson(json)).toList();
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<UserProfile> getUserProfile(String userId) async {
    final token = await _getTokenOrThrow();
    final response = await _client.get(
      Uri.parse('${ApiEndpoints.social}/profile/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return UserProfile.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<void> updatePrivacy(bool shareProgress) async {
    final token = await _getTokenOrThrow();
    final response = await _client.put(
      Uri.parse(ApiEndpoints.mePrivacy),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'shareProgress': shareProgress,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(
        _parseErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> updateProfile({String? bio, String? profilePictureUrl}) async {
    final token = await _getTokenOrThrow();
    final response = await _client.put(
      Uri.parse(ApiEndpoints.meProfile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'bio': ?bio,
        'profilePictureUrl': ?profilePictureUrl,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(
        _parseErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
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
