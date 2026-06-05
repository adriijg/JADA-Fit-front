import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CompletedStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static final Map<String, String> _webFallback = {};

  static const String _completedKey = 'completed_routines';
  static const String _exercisesKey = 'completed_exercises';

  Future<String?> _read(String key) async {
    if (kIsWeb) return _webFallback[key];
    return _storage.read(key: key);
  }

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      _webFallback[key] = value;
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<Set<int>> getCompletedRoutineIds() async {
    try {
      final raw = await _read(_completedKey);
      if (raw == null || raw.isEmpty) return {};
      final list = jsonDecode(raw) as List;
      return list.map((e) => e as int).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<Set<String>> getCompletedExerciseKeys() async {
    try {
      final raw = await _read(_exercisesKey);
      if (raw == null || raw.isEmpty) return {};
      final list = jsonDecode(raw) as List;
      return list.map((e) => e as String).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> markRoutineCompleted(int routineId) async {
    final ids = await getCompletedRoutineIds();
    ids.add(routineId);
    await _write(
      _completedKey,
      jsonEncode(ids.toList()),
    );
  }

  Future<void> markExerciseCompleted(int routineId, int exerciseIndex) async {
    final keys = await getCompletedExerciseKeys();
    keys.add('$routineId-$exerciseIndex');
    await _write(
      _exercisesKey,
      jsonEncode(keys.toList()),
    );
  }

  Future<Set<int>> getCompletedExerciseIndices(int routineId) async {
    final keys = await getCompletedExerciseKeys();
    final indices = <int>{};
    for (final key in keys) {
      final parts = key.split('-');
      if (parts.length == 2 && parts[0] == routineId.toString()) {
        indices.add(int.parse(parts[1]));
      }
    }
    return indices;
  }
}
