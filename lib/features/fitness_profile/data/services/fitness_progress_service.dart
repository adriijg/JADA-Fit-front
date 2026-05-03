import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/fitness_progress_model.dart';

class FitnessProgressService {
  FitnessProgressService({
    http.Client? client,
    SecureStorageService? storageService,
  }) : _client = client ?? http.Client(),
       _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<List<FitnessProgressModel>> getMyFitnessProgress() async {
    final token = await _getTokenOrThrow();

    final response = await _client.get(
      Uri.parse(ApiEndpoints.myFitnessProgress),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (item) =>
                FitnessProgressModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<FitnessProgressModel> createFitnessProgressLog({
    required double weight,
    double? bodyFat,
    double? muscleMass,
    required DateTime loggedAt,
  }) async {
    final token = await _getTokenOrThrow();

    final response = await _client.post(
      Uri.parse(ApiEndpoints.myFitnessProgress),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'weight': weight,
        'bodyFat': bodyFat,
        'muscleMass': muscleMass,
        'loggedAt': _formatDateTimeForApi(loggedAt),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return FitnessProgressModel.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  String _formatDateTimeForApi(DateTime dateTime) {
    return dateTime.toIso8601String().split('.').first;
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

    return body.isNotEmpty ? body : 'No se pudo cargar el progreso físico';
  }
}
