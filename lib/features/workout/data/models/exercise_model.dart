class ExerciseModel {
  final int? id;
  final String name;
  final String description;
  final int sets;
  final int reps;
  final int durationSeconds;

  const ExerciseModel({
    this.id,
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    required this.durationSeconds,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sets: json['sets'] as int? ?? 0,
      reps: json['reps'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'description': description,
        'sets': sets,
        'reps': reps,
        'durationSeconds': durationSeconds,
      };
}
