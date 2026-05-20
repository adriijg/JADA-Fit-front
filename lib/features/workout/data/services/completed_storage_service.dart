import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CompletedStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _completedKey = 'completed_routines';
  static const String _exercisesKey = 'completed_exercises';

  Future<Set<int>> getCompletedRoutineIds() async {
    try {
      final raw = await _storage.read(key: _completedKey);
      if (raw == null || raw.isEmpty) return {};
      final list = jsonDecode(raw) as List;
      return list.map((e) => e as int).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<Set<String>> getCompletedExerciseKeys() async {
    try {
      final raw = await _storage.read(key: _exercisesKey);
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
    await _storage.write(
      key: _completedKey,
      value: jsonEncode(ids.toList()),
    );
  }

  Future<void> markExerciseCompleted(int routineId, int exerciseIndex) async {
    final keys = await getCompletedExerciseKeys();
    keys.add('$routineId-$exerciseIndex');
    await _storage.write(
      key: _exercisesKey,
      value: jsonEncode(keys.toList()),
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
