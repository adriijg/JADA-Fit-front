import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/network/auth_http_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/challenge.dart';
import '../models/user_exercise_record.dart';

class ChallengeService {
  ChallengeService({
    http.Client? client,
  }) : _client = client ?? AuthHttpClient();

  final http.Client _client;

  Future<Challenge> createChallenge(
    String challengedId,
    String exerciseName,
    double targetWeightKg,
  ) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.challenges),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'challengedId': challengedId,
        'exerciseName': exerciseName,
        'targetWeightKg': targetWeightKg,
      }),
    );

    if (response.statusCode == 200) {
      return Challenge.fromJson(jsonDecode(response.body));
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<Challenge> acceptChallenge(String challengeId) async {
    final response = await _client.post(
      Uri.parse('${ApiEndpoints.challenges}/$challengeId/accept'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Challenge.fromJson(jsonDecode(response.body));
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<Challenge> rejectChallenge(String challengeId) async {
    final response = await _client.post(
      Uri.parse('${ApiEndpoints.challenges}/$challengeId/reject'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Challenge.fromJson(jsonDecode(response.body));
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<List<Challenge>> getMyChallenges() async {
    final response = await _client.get(
      Uri.parse(ApiEndpoints.myChallenges),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Challenge.fromJson(json)).toList();
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<Challenge> addProgress(String challengeId, double weight) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.challengeProgress(challengeId)),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'weight': weight,
        'entryDate': DateTime.now().toIso8601String().split('T').first,
      }),
    );

    if (response.statusCode == 200) {
      return Challenge.fromJson(jsonDecode(response.body));
    }

    throw ApiException(
      _parseErrorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<void> updateRecord(String exerciseName, double maxWeight) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.exerciseRecords),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'exerciseName': exerciseName,
        'maxWeight': maxWeight,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        _parseErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<UserExerciseRecord>> getMyRecords() async {
    final response = await _client.get(
      Uri.parse(ApiEndpoints.myExerciseRecords),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserExerciseRecord.fromJson(json)).toList();
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
    return body.isNotEmpty ? body : 'An unexpected error occurred';
  }
}
