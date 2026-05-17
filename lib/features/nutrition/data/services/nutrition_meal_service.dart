import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/meal_type.dart';
import '../models/nutrition_day_summary_model.dart';
import '../models/nutrition_meal_model.dart';
import '../models/recipe_model.dart';

class NutritionMealService {
  NutritionMealService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<NutritionMealModel> createMeal({
    required String foodName,
    required MealType mealType,
    required double quantityGrams,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatsPer100g,
    required DateTime loggedAt,
    String? externalFoodId,
  }) async {
    final token = await _getTokenOrThrow();

    final response = await _client.post(
      Uri.parse(ApiEndpoints.nutritionMeals),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'externalFoodId': externalFoodId,
        'foodName': foodName,
        'mealType': mealType.apiValue,
        'quantityGrams': quantityGrams,
        'caloriesPer100g': caloriesPer100g,
        'proteinPer100g': proteinPer100g,
        'carbsPer100g': carbsPer100g,
        'fatsPer100g': fatsPer100g,
        'loggedAt': _formatDateTimeForApi(loggedAt),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return NutritionMealModel.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(
        response.body,
        fallback: 'No se pudo registrar la comida',
        statusCode: response.statusCode,
      ),
      statusCode: response.statusCode,
    );
  }

  Future<NutritionDaySummaryModel> getDaySummary({
    required DateTime date,
  }) async {
    final token = await _getTokenOrThrow();

    final uri = Uri.parse(ApiEndpoints.nutritionDay).replace(
      queryParameters: {
        'date': _formatDateForApi(date),
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
      final Map<String, dynamic> data = jsonDecode(response.body);
      return NutritionDaySummaryModel.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(
        response.body,
        fallback: 'No se pudo cargar el resumen nutricional',
        statusCode: response.statusCode,
      ),
      statusCode: response.statusCode,
    );
  }

  Future<void> deleteMeal({
    required String mealId,
  }) async {
    final token = await _getTokenOrThrow();

    final response = await _client.delete(
      Uri.parse('${ApiEndpoints.nutritionMeals}/$mealId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw ApiException(
      _parseErrorMessage(
        response.body,
        fallback: 'No se pudo eliminar la comida',
        statusCode: response.statusCode,
      ),
      statusCode: response.statusCode,
    );
  }

  Future<List<NutritionMealModel>> createMealsFromRecipe({
    required RecipeModel recipe,
    required MealType mealType,
    required DateTime loggedAt,
  }) async {
    final token = await _getTokenOrThrow();

    final response = await _client.post(
      Uri.parse(ApiEndpoints.nutritionMealsFromRecipe),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'recipeId': recipe.id,
        'mealType': mealType.apiValue,
        'loggedAt': _formatDateTimeForApi(loggedAt),
      }),
    );

    if (response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => NutritionMealModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      _parseErrorMessage(
        response.body,
        fallback: 'No se pudo añadir la receta',
        statusCode: response.statusCode,
      ),
      statusCode: response.statusCode,
    );
  }

  Future<String> _getTokenOrThrow() async {
    final token = await _storageService.getToken();

    if (token == null || token.isEmpty) {
      throw ApiException('No hay sesión activa');
    }

    return token;
  }

  String _formatDateForApi(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _formatDateTimeForApi(DateTime dateTime) {
    return dateTime.toIso8601String().split('.').first;
  }

  String _parseErrorMessage(
    String body, {
    required String fallback,
    required int statusCode,
  }) {
    if (statusCode == 401 || statusCode == 403) {
      return 'No autorizado. Vuelve a iniciar sesión.';
    }

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

    if (body.trim().isNotEmpty) {
      return body;
    }

    return fallback;
  }
}
