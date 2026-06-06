import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/auth_http_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/recipe_model.dart';

class RecipeService {
  RecipeService({
    http.Client? client,
  }) : _client = client ?? AuthHttpClient();

  final http.Client _client;

  Future<List<RecipeModel>> getMyRecipes() async {
    final response = await _client.get(
      Uri.parse(ApiEndpoints.recipes),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<RecipeModel> createRecipe(Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.recipes),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return RecipeModel.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<RecipeModel> updateRecipe(String recipeId, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse(ApiEndpoints.recipeById(recipeId)),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return RecipeModel.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<void> deleteRecipe(String recipeId) async {
    final response = await _client.delete(
      Uri.parse(ApiEndpoints.recipeById(recipeId)),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
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
        if (decoded['message'] is String) {
          return decoded['message'] as String;
        }

        if (decoded['error'] is String) {
          return decoded['error'] as String;
        }
      }
    } catch (_) {
    }

    return body.isNotEmpty ? body : 'Error al procesar la receta';
  }
}
