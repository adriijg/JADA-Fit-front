import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/auth_http_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/onboarding_response_model.dart';

class OnboardingService {
  OnboardingService({
    http.Client? client,
  }) : _client = client ?? AuthHttpClient();

  final http.Client _client;

  Future<OnboardingResponseModel> completeOnboarding({
    required double weight,
    required int height,
    required String dateOfBirth,
    required String gender,
    required String goal,
    double? bodyFat,
    double? muscleMass,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.completeOnboarding),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'weight': weight,
        'height': height,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'goal': goal,
        'bodyFat': bodyFat,
        'muscleMass': muscleMass,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return OnboardingResponseModel.fromJson(data);
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

    return body.isNotEmpty ? body : 'No se pudo completar el onboarding';
  }
}
