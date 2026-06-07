import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/auth_http_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/catalog_exercise_model.dart';

class CatalogExerciseService {
  CatalogExerciseService({
    http.Client? client,
  }) : _client = client ?? AuthHttpClient();

  final http.Client _client;

  Future<List<CatalogExerciseModel>> getAllExercises() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiEndpoints.catalogExercises),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => CatalogExerciseModel.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load exercises: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Connection error loading exercises: $e');
    }
  }

  Future<List<CatalogExerciseModel>> searchExercises(String query) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.catalogExercises}/search').replace(
        queryParameters: {'q': query},
      );
      
      final response = await _client.get(
        uri, 
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => CatalogExerciseModel.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to search exercises: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Connection error searching exercises: $e');
    }
  }
}
