import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/water_log_model.dart';

class WaterLogService {
  WaterLogService({
    http.Client? client,
    SecureStorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  final http.Client _client;
  final SecureStorageService _storageService;

  Future<WaterDaySummaryModel> getTodaySummary() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('No hay sesión activa');
    }

    final response = await _client.get(
      Uri.parse(ApiEndpoints.waterToday),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return WaterDaySummaryModel.fromJson(data);
    }

    throw ApiException('Error al cargar el resumen de agua',
        statusCode: response.statusCode);
  }

  Future<WaterLogModel> setLog(double amountMl) async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('No hay sesión activa');
    }

    final response = await _client.post(
      Uri.parse(ApiEndpoints.water),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amountMl': amountMl,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return WaterLogModel.fromJson(data);
    }

    throw ApiException('Error al registrar agua',
        statusCode: response.statusCode);
  }
}
