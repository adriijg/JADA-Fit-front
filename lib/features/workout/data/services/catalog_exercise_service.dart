import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/catalog_exercise_model.dart';

class CatalogExerciseService {
  CatalogExerciseService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<String> _getTokenOrThrow() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('No hay sesión activa');
    }
    return token;
  }

  Future<List<CatalogExerciseModel>> getAllExercises() async {
    try {
      final token = await _getTokenOrThrow();
      final response = await _client.get(
        Uri.parse(ApiEndpoints.catalogExercises),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => CatalogExerciseModel.fromJson(json)).toList();
      } else {
        throw ApiException('Error al cargar ejercicios: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error de conexión al cargar ejercicios: $e');
    }
  }

  Future<List<CatalogExerciseModel>> searchExercises(String query) async {
    try {
      final token = await _getTokenOrThrow();
      final uri = Uri.parse('${ApiEndpoints.catalogExercises}/search').replace(
        queryParameters: {'q': query},
      );
      
      final response = await _client.get(
        uri, 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => CatalogExerciseModel.fromJson(json)).toList();
      } else {
        throw ApiException('Error al buscar ejercicios: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error de conexión al buscar ejercicios: $e');
    }
  }
}
