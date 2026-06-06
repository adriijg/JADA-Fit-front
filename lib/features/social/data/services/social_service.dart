import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/network/auth_http_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../models/user_profile.dart';
import '../models/user_summary.dart';

class SocialService {
  SocialService({
    http.Client? client,
  }) : _client = client ?? AuthHttpClient();

  final http.Client _client;

  Future<void> followUser(String userId) async {
    final response = await _client.post(
      Uri.parse('${ApiEndpoints.follow}/$userId'),
      headers: {
        'Content-Type': 'application/json',
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
    final response = await _client.delete(
      Uri.parse('${ApiEndpoints.unfollow}/$userId'),
      headers: {
        'Content-Type': 'application/json',
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
    final response = await _client.get(
      Uri.parse('${ApiEndpoints.social}/$userId/followers'),
      headers: {
        'Content-Type': 'application/json',
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
    final response = await _client.get(
      Uri.parse('${ApiEndpoints.social}/$userId/following'),
      headers: {
        'Content-Type': 'application/json',
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
    final response = await _client.get(
      Uri.parse('${ApiEndpoints.social}/users/search?q=$query'),
      headers: {
        'Content-Type': 'application/json',
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
    final response = await _client.get(
      Uri.parse('${ApiEndpoints.social}/profile/$userId'),
      headers: {
        'Content-Type': 'application/json',
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
    final response = await _client.put(
      Uri.parse(ApiEndpoints.mePrivacy),
      headers: {
        'Content-Type': 'application/json',
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
    final serverProfilePictureUrl = profilePictureUrl != null &&
            profilePictureUrl.isNotEmpty &&
            !ImageUrlResolver.isServerImageUrl(profilePictureUrl)
        ? await UploadService().uploadImage(profilePictureUrl)
        : profilePictureUrl;

    final response = await _client.put(
      Uri.parse(ApiEndpoints.meProfile),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'bio': bio,
        'profilePictureUrl': serverProfilePictureUrl,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(
        _parseErrorMessage(response.body),
        statusCode: response.statusCode,
      );
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
