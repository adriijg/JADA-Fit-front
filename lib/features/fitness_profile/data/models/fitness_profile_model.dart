class FitnessProfileModel {
  const FitnessProfileModel({
    required this.userId,
    required this.username,
    required this.email,
    this.weight,
    this.height,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.goal,
    this.bodyFat,
    this.muscleMass,
    this.updatedAt,
  });

  final String userId;
  final String username;
  final String email;
  final double? weight;
  final int? height;
  final String? dateOfBirth;
  final int? age;
  final String? gender;
  final String? goal;
  final double? bodyFat;
  final double? muscleMass;
  final DateTime? updatedAt;

  factory FitnessProfileModel.fromJson(Map<String, dynamic> json) {
    return FitnessProfileModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      weight: _toDoubleOrNull(json['weight']),
      height: _toIntOrNull(json['height']),
      dateOfBirth: json['dateOfBirth'] as String?,
      age: _toIntOrNull(json['age']),
      gender: json['gender'] as String?,
      goal: json['goal'] as String?,
      bodyFat: _toDoubleOrNull(json['bodyFat']),
      muscleMass: _toDoubleOrNull(json['muscleMass']),
      updatedAt: _toDateTimeOrNull(json['updatedAt']),
    );
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;

    if (value is int) return value.toDouble();

    if (value is double) return value;

    if (value is String) return double.tryParse(value);

    return null;
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is String) return int.tryParse(value);

    return null;
  }

  static DateTime? _toDateTimeOrNull(dynamic value) {
    if (value == null) return null;

    if (value is String) return DateTime.tryParse(value);

    return null;
  }
}
