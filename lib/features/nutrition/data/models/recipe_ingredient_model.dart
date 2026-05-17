class RecipeIngredientModel {
  const RecipeIngredientModel({
    required this.id,
    required this.foodName,
    required this.quantityGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final String id;
  final String foodName;
  final double quantityGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      id: json['id'] as String,
      foodName: json['foodName'] as String,
      quantityGrams: _toDouble(json['quantityGrams']),
      calories: _toDouble(json['calories']),
      protein: _toDouble(json['protein']),
      carbs: _toDouble(json['carbs']),
      fats: _toDouble(json['fats']),
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
