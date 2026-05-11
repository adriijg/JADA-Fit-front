import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/routine_model.dart';

class RoutineService {
  RoutineService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<List<RoutineModel>> getRoutines() async {
    final token = await _getTokenOrThrow();

    final response = await _client.get(
      Uri.parse(ApiEndpoints.routines),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => RoutineModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      _parseErrorMessage(
        response.body,
        fallback: 'No se pudieron cargar las rutinas',
        statusCode: response.statusCode,
      ),
      statusCode: response.statusCode,
    );
  }

  Future<RoutineModel> createRoutine(RoutineModel routine) async {
    final token = await _getTokenOrThrow();

    final response = await _client.post(
      Uri.parse(ApiEndpoints.routines),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(routine.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return RoutineModel.fromJson(data);
    }

    throw ApiException(
      _parseErrorMessage(
        response.body,
        fallback: 'No se pudo crear la rutina',
        statusCode: response.statusCode,
      ),
      statusCode: response.statusCode,
    );
  }

  Future<void> deleteRoutine(int id) async {
    final token = await _getTokenOrThrow();

    final response = await _client.delete(
      Uri.parse(ApiEndpoints.routineById(id)),
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
        fallback: 'No se pudo eliminar la rutina',
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

  String _parseErrorMessage(
    String body, {
    required String fallback,
    required int statusCode,
  }) {
    // DEBUG: return 'DEBUG: $statusCode - $body';
    if (statusCode == 401 || statusCode == 403) {
      return 'No autorizado ($statusCode). Prueba a cerrar sesión y entrar de nuevo.';
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

    if (body.trim().isNotEmpty) return body;

    return fallback;
  }
}
