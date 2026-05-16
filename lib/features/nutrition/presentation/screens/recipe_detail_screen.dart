import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/recipe_model.dart';
import '../../data/services/recipe_service.dart';
import 'create_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  final RecipeModel recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeService _recipeService = RecipeService();
  late RecipeModel _recipe;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  Future<void> _refreshRecipe() async {
    setState(() => _isLoading = true);
    try {
      final recipes = await _recipeService.getMyRecipes();
      final updated = recipes.where((r) => r.id == _recipe.id).firstOrNull;
      if (updated != null && mounted) {
        setState(() => _recipe = updated);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _editRecipe() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRecipeScreen(recipe: _recipe),
      ),
    );

    if (result == true && mounted) {
      _refreshRecipe();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          _recipe.name,
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: _editRecipe,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MacroTotalCard(recipe: _recipe),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'INGREDIENTES',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_recipe.ingredients.length}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_recipe.servings != null) ...[
                  const Spacer(),
                  Text(
                    '${_recipe.servings} porciones',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            ..._recipe.ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _IngredientDetailCard(ingredient: ingredient),
            )),
          ],
        ),
      ),
    );
  }
}

class _MacroTotalCard extends StatelessWidget {
  const _MacroTotalCard({
    required this.recipe,
  });

  final RecipeModel recipe;

  String _f(double v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard.primary(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const AppCardIcon(
                icon: Icons.menu_book,
                size: 48,
                borderRadius: 16,
                borderColor: AppColors.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (recipe.servings != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${recipe.servings} porciones',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MacroBlock(
                label: 'Calorías',
                value: '${_f(recipe.totalCalories)} kcal',
              ),
              const SizedBox(width: 8),
              _MacroBlock(
                label: 'Proteína',
                value: '${_f(recipe.totalProtein)} g',
              ),
              const SizedBox(width: 8),
              _MacroBlock(
                label: 'Hidratos',
                value: '${_f(recipe.totalCarbs)} g',
              ),
              const SizedBox(width: 8),
              _MacroBlock(
                label: 'Grasas',
                value: '${_f(recipe.totalFats)} g',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroBlock extends StatelessWidget {
  const _MacroBlock({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard.input(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientDetailCard extends StatelessWidget {
  const _IngredientDetailCard({
    required this.ingredient,
  });

  final dynamic ingredient;

  String _f(double v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const AppCardIcon(
            icon: Icons.restaurant,
            size: 40,
            borderRadius: 14,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.foodName,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_f(ingredient.quantityGrams)} g · '
                  '${_f(ingredient.calories)} kcal · '
                  'P ${_f(ingredient.protein)}g · '
                  'C ${_f(ingredient.carbs)}g · '
                  'G ${_f(ingredient.fats)}g',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
