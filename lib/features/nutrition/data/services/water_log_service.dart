import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/auth_http_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/water_log_model.dart';

class WaterLogService {
  WaterLogService({
    http.Client? client,
  }) : _client = client ?? AuthHttpClient();

  final http.Client _client;

  Future<WaterDaySummaryModel> getTodaySummary() async {
    final response = await _client.get(
      Uri.parse(ApiEndpoints.waterToday),
      headers: {
        'Content-Type': 'application/json',
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
    final response = await _client.post(
      Uri.parse(ApiEndpoints.water),
      headers: {
        'Content-Type': 'application/json',
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
