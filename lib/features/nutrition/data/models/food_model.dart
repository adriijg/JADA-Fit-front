class FoodModel {
  const FoodModel({
    required this.id,
    required this.externalId,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    required this.isCustom,
  });

  final String id;
  final String externalId;
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;
  final bool isCustom;

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as String,
      externalId: json['externalId'] as String,
      name: json['name'] as String,
      caloriesPer100g: _toDouble(json['caloriesPer100g']),
      proteinPer100g: _toDouble(json['proteinPer100g']),
      carbsPer100g: _toDouble(json['carbsPer100g']),
      fatsPer100g: _toDouble(json['fatsPer100g']),
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}
