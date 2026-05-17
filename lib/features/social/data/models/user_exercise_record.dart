class UserExerciseRecord {
  final String exerciseName;
  final double maxWeight;
  final DateTime updatedAt;

  UserExerciseRecord({
    required this.exerciseName,
    required this.maxWeight,
    required this.updatedAt,
  });

  factory UserExerciseRecord.fromJson(Map<String, dynamic> json) {
    return UserExerciseRecord(
      exerciseName: json['exerciseName'],
      maxWeight: (json['maxWeight'] ?? 0.0).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
