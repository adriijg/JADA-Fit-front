import 'meal_type.dart';

class NutritionMealModel {
  const NutritionMealModel({
    required this.id,
    required this.foodName,
    required this.mealType,
    required this.quantityGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.loggedAt,
    this.externalFoodId,
  });

  final String id;
  final String? externalFoodId;
  final String foodName;
  final MealType mealType;
  final double quantityGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final DateTime loggedAt;

  factory NutritionMealModel.fromJson(Map<String, dynamic> json) {
    return NutritionMealModel(
      id: json['id'] as String,
      externalFoodId: json['externalFoodId'] as String?,
      foodName: json['foodName'] as String,
      mealType: MealTypeExtension.fromApiValue(json['mealType'] as String),
      quantityGrams: _toDouble(json['quantityGrams']),
      calories: _toDouble(json['calories']),
      protein: _toDouble(json['protein']),
      carbs: _toDouble(json['carbs']),
      fats: _toDouble(json['fats']),
      loggedAt: DateTime.parse(json['loggedAt'] as String),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value.toDouble();

    if (value is double) return value;

    if (value is num) return value.toDouble();

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}