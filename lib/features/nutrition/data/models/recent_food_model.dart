class RecentFoodModel {
  const RecentFoodModel({
    required this.id,
    required this.foodName,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    required this.lastLoggedAt,
    this.foodSource,
  });

  final String id;
  final String foodName;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;
  final DateTime lastLoggedAt;
  final String? foodSource;

  bool get isUserCreated => foodSource == 'USER';

  factory RecentFoodModel.fromJson(Map<String, dynamic> json) {
    return RecentFoodModel(
      id: json['id'] as String,
      foodName: json['foodName'] as String,
      caloriesPer100g: _toDouble(json['caloriesPer100g']),
      proteinPer100g: _toDouble(json['proteinPer100g']),
      carbsPer100g: _toDouble(json['carbsPer100g']),
      fatsPer100g: _toDouble(json['fatsPer100g']),
      lastLoggedAt: DateTime.parse(json['lastLoggedAt'] as String),
      foodSource: json['foodSource'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
