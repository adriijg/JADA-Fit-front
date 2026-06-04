import 'exercise_model.dart';
import 'routine_goal.dart';
import 'routine_split.dart';

class RoutineModel {
  final int? id;
  final String name;
  final String description;
  final String targetGoal;
  final String routineSplit;
  final bool isCompleted;
  final List<ExerciseModel> exercises;

  const RoutineModel({
    this.id,
    required this.name,
    required this.description,
    required this.targetGoal,
    this.routineSplit = '',
    this.isCompleted = false,
    this.exercises = const [],
  });

  RoutineGoal? get goalEnum => RoutineGoal.fromString(targetGoal);
  RoutineSplit? get splitEnum => RoutineSplit.fromString(routineSplit);

  RoutineModel copyWith({
    int? id,
    String? name,
    String? description,
    String? targetGoal,
    String? routineSplit,
    bool? isCompleted,
    List<ExerciseModel>? exercises,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetGoal: targetGoal ?? this.targetGoal,
      routineSplit: routineSplit ?? this.routineSplit,
      isCompleted: isCompleted ?? this.isCompleted,
      exercises: exercises ?? this.exercises,
    );
  }

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
      routineSplit: json['routineSplit'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      exercises: exercises,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'targetGoal': targetGoal,
        'routineSplit': routineSplit,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  Map<String, dynamic> toUpdateJson() => {
        'id': id,
        'name': name,
        'description': description,
        'targetGoal': targetGoal,
        'routineSplit': routineSplit,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}
