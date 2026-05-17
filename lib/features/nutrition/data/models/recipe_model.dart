import 'recipe_ingredient_model.dart';

class RecipeModel {
  const RecipeModel({
    required this.id,
    required this.name,
    this.servings,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.ingredients,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int? servings;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final List<RecipeIngredientModel> ingredients;
  final DateTime createdAt;

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      servings: json['servings'] as int?,
      totalCalories: _toDouble(json['totalCalories']),
      totalProtein: _toDouble(json['totalProtein']),
      totalCarbs: _toDouble(json['totalCarbs']),
      totalFats: _toDouble(json['totalFats']),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => RecipeIngredientModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
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
