import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/auth_http_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/profile_model.dart';

class ProfileService {
  ProfileService({
    http.Client? client,
  }) : _client = client ?? AuthHttpClient();

  final http.Client _client;

  Future<ProfileModel> getMyProfile() async {
    final response = await _client.get(
      Uri.parse(ApiEndpoints.myFitnessProfile),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ProfileModel.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<ProfileModel> updateMyProfile({
    double? weight,
    int? height,
    String? dateOfBirth,
    String? gender,
    String? goal,
    double? bodyFat,
    double? muscleMass,
  }) async {
    final response = await _client.put(
      Uri.parse(ApiEndpoints.myFitnessProfile),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'weight': weight,
        'height': height,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'goal': _emptyToNull(goal),
        'bodyFat': bodyFat,
        'muscleMass': muscleMass,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ProfileModel.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  String? _emptyToNull(String? value) {
    if (value == null) return null;

    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
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

    return body.isNotEmpty ? body : 'No se pudo cargar el perfil';
  }
}
