import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/food_model.dart';

class FoodService {
  FoodService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<FoodModel> getFoodByBarcode(String barcode) async {
    final token = await _storageService.getToken();

    if (token == null || token.isEmpty) {
      throw ApiException('No hay sesión activa');
    }

    final response = await _client.get(
      Uri.parse(ApiEndpoints.foodByBarcode(barcode)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return FoodModel.fromJson(data);
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

    return body.isNotEmpty ? body : 'No se pudo buscar el alimento';
  }
}
