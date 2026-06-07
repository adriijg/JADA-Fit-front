import 'dart:convert';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'auth_http_client.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

class UploadService {
  UploadService({
    http.Client? client,
  }) : _client = client ?? AuthHttpClient();

  final http.Client _client;

  Future<String> uploadImage(String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiEndpoints.uploadImage),
    );

    Uint8List bytes;
    final filename = filePath.split('/').last;

    if (kIsWeb) {
      final fileResponse = await _client.get(Uri.parse(filePath));
      bytes = fileResponse.bodyBytes;
    } else {
      bytes = await XFile(filePath).readAsBytes();
    }

    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['url'] as String;
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
        if (decoded['message'] is String) return decoded['message'] as String;
        if (decoded['error'] is String) return decoded['error'] as String;
      }
    } catch (_) {}
    return body.isNotEmpty ? body : 'Ocurrió un error inesperado';
  }
}
