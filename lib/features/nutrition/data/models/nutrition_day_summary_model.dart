import 'nutrition_meal_model.dart';

class NutritionDaySummaryModel {
  const NutritionDaySummaryModel({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.caloriesTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatsTarget,
    required this.meals,
  });

  final DateTime date;

  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;

  final double caloriesTarget;
  final double proteinTarget;
  final double carbsTarget;
  final double fatsTarget;

  final List<NutritionMealModel> meals;

  factory NutritionDaySummaryModel.fromJson(Map<String, dynamic> json) {
    final rawMeals = json['meals'];

    return NutritionDaySummaryModel(
      date: DateTime.parse(json['date'] as String),
      totalCalories: _toDouble(json['totalCalories']),
      totalProtein: _toDouble(json['totalProtein']),
      totalCarbs: _toDouble(json['totalCarbs']),
      totalFats: _toDouble(json['totalFats']),
      caloriesTarget: _toDouble(json['caloriesTarget']),
      proteinTarget: _toDouble(json['proteinTarget']),
      carbsTarget: _toDouble(json['carbsTarget']),
      fatsTarget: _toDouble(json['fatsTarget']),
      meals: rawMeals is List
          ? rawMeals
              .map(
                (item) => NutritionMealModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList()
          : const [],
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