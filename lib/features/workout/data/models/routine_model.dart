import 'exercise_model.dart';

class RoutineModel {
  final int? id;
  final String name;
  final String description;
  final String targetGoal;
  final List<ExerciseModel> exercises;

  const RoutineModel({
    this.id,
    required this.name,
    required this.description,
    required this.targetGoal,
    this.exercises = const [],
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'];
    final exercises = rawExercises is List
        ? rawExercises
            .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <ExerciseModel>[];

    return RoutineModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetGoal: json['targetGoal'] as String? ?? '',
      exercises: exercises,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'targetGoal': targetGoal,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}
