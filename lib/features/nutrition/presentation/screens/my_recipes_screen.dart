import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/meal_type.dart';
import '../../data/models/recipe_model.dart';
import '../../data/services/nutrition_meal_service.dart';
import '../../data/services/recipe_service.dart';
import 'create_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class MyRecipesScreen extends StatefulWidget {
  MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  final RecipeService _recipeService = RecipeService();
  final NutritionMealService _nutritionMealService = NutritionMealService();
  final TextEditingController _searchController = TextEditingController();

  List<RecipeModel> _recipes = [];
  List<RecipeModel> _filteredRecipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _filterRecipes(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredRecipes = List.from(_recipes);
      } else {
        final q = query.trim().toLowerCase();
        _filteredRecipes = _recipes
            .where((r) => r.name.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final recipes = await _recipeService.getMyRecipes();

      if (!mounted) return;

      setState(() {
        _recipes = recipes;
        _filterRecipes(_searchController.text);
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'No se pudieron cargar las recetas';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshRecipes() async {
    try {
      final recipes = await _recipeService.getMyRecipes();

      if (!mounted) return;

      setState(() {
        _recipes = recipes;
        _errorMessage = null;
        _filterRecipes(_searchController.text);
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'No se pudieron cargar las recetas';
      });
    }
  }

  Future<void> _deleteRecipe(RecipeModel recipe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.nutritionDeleteRecipe,
          style: TextStyle(color: context.colors.textMain, fontWeight: FontWeight.w800),
        ),
        content: Text(
          AppLocalizations.of(context)!.nutritionDeleteRecipeConfirm(recipe.name),
          style: TextStyle(color: context.colors.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppLocalizations.of(context)!.nutritionCancel,
              style: TextStyle(color: context.colors.secondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.of(context)!.nutritionDelete,
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _recipeService.deleteRecipe(recipe.id);

      await _refreshRecipes();
    } on ApiException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.nutritionErrorDeletingRecipe),
        ),
      );
    }
  }

  void _openCreateRecipe() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRecipeScreen(),
      ),
    );

    if (created == true) {
      await _refreshRecipes();
    }
  }

  void _showAddToDaySheet(RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.nutritionAddRecipeTo,
              style: TextStyle(
                color: context.colors.secondary,
                fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 16),
            AppBottomSheetSimpleOption(
              icon: Icons.free_breakfast,
              label: MealType.breakfast.label,
              onTap: () {
                Navigator.pop(context);
                _addRecipeToMeal(recipe, MealType.breakfast);
              },
            ),
            AppBottomSheetSimpleOption(
              icon: Icons.lunch_dining,
              label: MealType.lunch.label,
              onTap: () {
                Navigator.pop(context);
                _addRecipeToMeal(recipe, MealType.lunch);
              },
            ),
            AppBottomSheetSimpleOption(
              icon: Icons.dinner_dining,
              label: MealType.dinner.label,
              onTap: () {
                Navigator.pop(context);
                _addRecipeToMeal(recipe, MealType.dinner);
              },
            ),
            AppBottomSheetSimpleOption(
              icon: Icons.cookie_outlined,
              label: MealType.snack.label,
              onTap: () {
                Navigator.pop(context);
                _addRecipeToMeal(recipe, MealType.snack);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addRecipeToMeal(RecipeModel recipe, MealType mealType) async {
    try {
      final meals = await _nutritionMealService.createMealsFromRecipe(
        recipe: recipe,
        mealType: mealType,
        loggedAt: DateTime.now(),
      );

      if (!mounted) return;

      if (meals.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.nutritionRecipeAddedToMeal(recipe.name, mealType.localizedLabel(AppLocalizations.of(context)!).toLowerCase())),
          ),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.nutritionErrorAddingRecipe),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.nutritionMyRecipes,
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateRecipe,
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.add, size: 28),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.colors.inputBorder,
            width: 0.7,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterRecipes,
          style: TextStyle(
            color: context.colors.textMain,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.nutritionSearchRecipe,
            hintStyle: TextStyle(
              color: context.colors.textMain.withOpacity(0.4),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: context.colors.secondary,
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: context.colors.secondary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _filterRecipes('');
                    },
                  )
                : null,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textMain,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadRecipes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.nutritionRetry),
              ),
            ],
          ),
        ),
      );
    }

    if (_recipes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                color: context.colors.secondary.withOpacity(0.5),
                size: 64,
              ),
              SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.nutritionRecipesEmpty,
                style: TextStyle(
                  color: context.colors.textMain,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.nutritionCreateFirstRecipe,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _openCreateRecipe,
                icon: Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context)!.nutritionCreateRecipe),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredRecipes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                color: context.colors.secondary,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.nutritionNoMatchingRecipes,
                style: TextStyle(
                  color: context.colors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.nutritionRecipesSearchEmpty,
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecipes,
      color: context.colors.primary,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 96),
        itemCount: _filteredRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _filteredRecipes[index];
          return _RecipeCard(
            recipe: recipe,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(recipe: recipe),
                ),
              );
            },
            onDelete: () => _deleteRecipe(recipe),
            onAddToDay: () => _showAddToDaySheet(recipe),
          );
        },
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.onDelete,
    required this.onAddToDay,
    this.onTap,
  });

  final RecipeModel recipe;
  final VoidCallback onDelete;
  final VoidCallback onAddToDay;
  final VoidCallback? onTap;

  String _formatDouble(double value, String unit) {
    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }
    return '${value.toStringAsFixed(1)} $unit';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: AppCard.elevated(
        onTap: onTap,
        borderRadius: 24,
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              AppCardIcon(
                icon: Icons.menu_book,
                size: 44,
                borderRadius: 16,
                borderColor: context.colors.primary.withOpacity(0.22),
                iconSize: 22,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (recipe.servings != null) ...[
                          Text(
                            '${recipe.servings} porc.',
                            style: TextStyle(
                              color: context.colors.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                        Text(
                          '${recipe.ingredients.length} ingr.',
                          style: TextStyle(
                            color: context.colors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          _formatDate(recipe.createdAt),
                          style: TextStyle(
                            color: context.colors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.colors.inputBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: context.colors.secondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          AppCard.input(
            padding: EdgeInsets.all(12),
            borderRadius: 16,
            child: Row(
              children: [
                _MacroChip(
                  value: _formatDouble(recipe.totalCalories, 'kcal'),
                  highlighted: true,
                ),
                SizedBox(width: 8),
                _MacroChip(
                  value: 'P ${_formatDouble(recipe.totalProtein, 'g')}',
                ),
                SizedBox(width: 8),
                _MacroChip(
                  value: 'C ${_formatDouble(recipe.totalCarbs, 'g')}',
                ),
                SizedBox(width: 8),
                _MacroChip(
                  value: 'G ${_formatDouble(recipe.totalFats, 'g')}',
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddToDay,
              icon: Icon(Icons.add_circle_outline, size: 16),
              label: Text(AppLocalizations.of(context)!.nutritionAddToDay),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.primary,
                side: BorderSide(
                  color: context.colors.primary.withOpacity(0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.value,
    this.highlighted = false,
  });

  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: highlighted
              ? context.colors.primary.withOpacity(0.14)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: highlighted ? context.colors.primary : context.colors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


