class FitnessProgressModel {
  const FitnessProgressModel({
    required this.id,
    this.weight,
    this.bodyFat,
    this.muscleMass,
    required this.loggedAt,
  });

  final String id;
  final double? weight;
  final double? bodyFat;
  final double? muscleMass;
  final DateTime loggedAt;

  factory FitnessProgressModel.fromJson(Map<String, dynamic> json) {
    return FitnessProgressModel(
      id: json['id'] as String,
      weight: _toDoubleOrNull(json['weight']),
      bodyFat: _toDoubleOrNull(json['bodyFat']),
      muscleMass: _toDoubleOrNull(json['muscleMass']),
      loggedAt: DateTime.parse(json['loggedAt'] as String),
    );
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }
}