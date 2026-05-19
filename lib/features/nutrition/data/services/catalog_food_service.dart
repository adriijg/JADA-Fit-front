import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/catalog_food_model.dart';

class CatalogFoodService {
  CatalogFoodService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<List<CatalogFoodModel>> searchFoods(String query) async {
    final token = await _getTokenOrThrow();

    final uri = Uri.parse(ApiEndpoints.foodsSearch).replace(
      queryParameters: {
        'query': query,
      },
    );

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map(
              (item) => CatalogFoodModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      return const [];
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<CatalogFoodModel> getFoodByBarcode(String barcode) async {
    final token = await _getTokenOrThrow();

    final response = await _client.get(
      Uri.parse('${ApiEndpoints.foodsBarcode}/$barcode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CatalogFoodModel.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<CatalogFoodModel> createCustomFood({
    required String name,
    String? brand,
    String? barcode,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatsPer100g,
  }) async {
    final token = await _getTokenOrThrow();

    final response = await _client.post(
      Uri.parse(ApiEndpoints.foodsCustom),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        if (brand != null) 'brand': brand,
        if (barcode != null) 'barcode': barcode,
        'caloriesPer100g': caloriesPer100g,
        'proteinPer100g': proteinPer100g,
        'carbsPer100g': carbsPer100g,
        'fatsPer100g': fatsPer100g,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CatalogFoodModel.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<List<CatalogFoodModel>> getMyCustomFoods() async {
    final token = await _getTokenOrThrow();

    final response = await _client.get(
      Uri.parse(ApiEndpoints.myCustomFoods),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map((item) => CatalogFoodModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return const [];
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<void> deleteCustomFood(String foodId) async {
    final token = await _getTokenOrThrow();

    final response = await _client.delete(
      Uri.parse(ApiEndpoints.customFoodById(foodId)),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
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
        if (decoded['message'] is String) {
          return decoded['message'] as String;
        }

        if (decoded['error'] is String) {
          return decoded['error'] as String;
        }
      }
    } catch (_) {
      // fallback
    }

    return body.isNotEmpty ? body : 'No se pudo procesar la solicitud';
  }
}
