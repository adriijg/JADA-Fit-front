import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/catalog_food_model.dart';
import '../../data/models/meal_type.dart';
import '../../data/models/recent_food_model.dart';
import '../../data/models/recipe_model.dart';
import '../../data/services/catalog_food_service.dart';
import '../../data/services/nutrition_meal_service.dart';
import '../../data/services/recipe_service.dart';
import 'barcode_scanner_screen.dart';
import 'my_recipes_screen.dart';
import 'register_meal_screen.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({
    super.key,
    required this.initialMealType,
    required this.initialDate,
    this.pickerMode = false,
  });

  final MealType initialMealType;
  final DateTime initialDate;
  final bool pickerMode;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final CatalogFoodService _catalogFoodService = CatalogFoodService();
  final RecipeService _recipeService = RecipeService();
  final NutritionMealService _nutritionMealService = NutritionMealService();
  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  List<CatalogFoodModel> foods = const [];

  List<RecipeModel> _recipes = [];
  bool _isRecipesLoading = true;
  List<RecentFoodModel> _recentFoods = [];
  bool _isRecentFoodsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _loadRecentFoods();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes = await _recipeService.getMyRecipes();
      if (!mounted) return;
      recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() => _recipes = recipes);
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isRecipesLoading = false);
    }
  }

  Future<void> _openCreateFood() async {
    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterMealScreen.manualCreate(
          initialMealType: widget.initialMealType,
          initialDate: widget.initialDate,
        ),
      ),
    );
    if (registered == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _loadRecentFoods() async {
    try {
      final foods = await _nutritionMealService.getRecentFoods();
      if (!mounted) return;
      setState(() => _recentFoods = foods);
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error loading recent foods: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException ? e.message : 'Error al cargar alimentos recientes',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecentFoodsLoading = false);
    }
  }

  Future<void> _addRecipeToMeal(RecipeModel recipe) async {
    try {
      await _nutritionMealService.createMealsFromRecipe(
        recipe: recipe,
        mealType: widget.initialMealType,
        loggedAt: widget.initialDate,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => errorMessage = 'No se pudo añadir la receta');
    }
  }

  Future<void> _openViewAllRecipes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyRecipesScreen()),
    );
    if (!mounted) return;
    _loadRecipes();
  }

  Future<void> _deleteRecentFood(RecentFoodModel food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Eliminar alimento',
          style: TextStyle(color: AppColors.textMain),
        ),
        content: Text(
          '¿Eliminar "${food.foodName}" del historial?',
          style: const TextStyle(color: AppColors.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      await _nutritionMealService.deleteMeal(mealId: food.id);
      if (!mounted) return;
      setState(() => _recentFoods.removeWhere((f) => f.id == food.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alimento eliminado del historial'),
            backgroundColor: AppColors.surface,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar el alimento'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _searchFoods() async {
    final query = searchController.text.trim();

    if (query.length < 2) {
      setState(() {
        errorMessage = 'Escribe al menos 2 caracteres';
        foods = const [];
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await _catalogFoodService.searchFoods(query);

      if (!mounted) return;

      setState(() {
        foods = result;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'No se pudo buscar alimentos';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _scanFood() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerScreen(),
      ),
    );

    if (scannedCode == null || scannedCode.isEmpty) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final food = await _catalogFoodService.getFoodByBarcode(scannedCode);

      if (!mounted) return;

      await _openRegisterMeal(food);
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'No se pudo escanear el alimento';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _openRegisterMeal(CatalogFoodModel food) async {
    if (widget.pickerMode) {
      Navigator.pop(context, food);
      return;
    }

    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterMealScreen(
          food: food,
          initialMealType: widget.initialMealType,
          initialDate: widget.initialDate,
        ),
      ),
    );

    if (!mounted) return;

    if (registered == true) {
      Navigator.pop(context, true);
    }
  }

  String _formatDouble(double value, String unit) {
    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  String _sourceLabel(String source) {
    switch (source) {
      case 'USER':
        return 'Personalizado';
      case 'OPEN_FOOD_FACTS':
        return 'Open Food Facts';
      default:
        return source;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentRecipes = _recipes.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textMain,
        ),
        title: Text(
          widget.pickerMode
              ? 'Seleccionar alimento'
              : 'Añadir a ${widget.initialMealType.label.toLowerCase()}',
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _SearchCard(
                controller: searchController,
                isLoading: isLoading,
                onSearch: _searchFoods,
                onScan: _scanFood,
                onCreateFood: _openCreateFood,
              ),
              const SizedBox(height: 20),
              if (errorMessage != null)
                _ErrorCard(
                  message: errorMessage!,
                ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 28),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              if (!isLoading && foods.isEmpty && errorMessage == null) ...[
                if (!_isRecentFoodsLoading && _recentFoods.isNotEmpty) ...[
                  const Text(
                    'Registrados recientemente',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._recentFoods.take(5).map((food) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RecentFoodTile(
                      food: food,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterMealScreen.fromRecent(
                              foodName: food.foodName,
                              caloriesPer100g: food.caloriesPer100g,
                              proteinPer100g: food.proteinPer100g,
                              carbsPer100g: food.carbsPer100g,
                              fatsPer100g: food.fatsPer100g,
                              initialMealType: widget.initialMealType,
                              initialDate: widget.initialDate,
                            ),
                          ),
                        ).then((registered) {
                          if (registered == true && mounted) {
                            Navigator.pop(context, true);
                          }
                        });
                      },
                      onDelete: food.isUserCreated
                          ? () => _deleteRecentFood(food)
                          : null,
                    ),
                  )),
                  const SizedBox(height: 16),
                ],
                if (!_isRecipesLoading && recentRecipes.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tus recetas',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _openViewAllRecipes,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Ver todas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...recentRecipes.map((recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RecentRecipeTile(
                      recipe: recipe,
                      onTap: () => _addRecipeToMeal(recipe),
                    ),
                  )),
                ],
              ],
              if (!isLoading && foods.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: foods.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final food = foods[index];

                    final brand =
                        food.brand == null || food.brand!.trim().isEmpty
                            ? 'Sin marca'
                            : food.brand!;

                    return InkWell(
                      onTap: () => _openRegisterMeal(food),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.divider.withOpacity(0.4),
                            width: 0.7,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.inputBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.name,
                                    style: const TextStyle(
                                      color: AppColors.textMain,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '$brand · ${_sourceLabel(food.source)}',
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_formatDouble(food.caloriesPer100g, 'kcal')} / 100g · '
                                    'P ${_formatDouble(food.proteinPer100g, 'g')} · '
                                    'C ${_formatDouble(food.carbsPer100g, 'g')} · '
                                    'G ${_formatDouble(food.fatsPer100g, 'g')}',
                                    style: TextStyle(
                                      color: AppColors.textMain
                                          .withOpacity(0.58),
                                      fontSize: 11,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentFoodTile extends StatelessWidget {
  const _RecentFoodTile({
    required this.food,
    required this.onTap,
    this.onDelete,
  });

  final RecentFoodModel food;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.4),
            width: 0.7,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          food.foodName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMain,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (food.isUserCreated) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'TUYO',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${food.caloriesPer100g.toInt()} kcal / 100g',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (food.isUserCreated && onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'AÑADIR',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRecipeTile extends StatelessWidget {
  const _RecentRecipeTile({
    required this.recipe,
    required this.onTap,
  });

  final RecipeModel recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.4),
            width: 0.7,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.menu_book,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${recipe.totalCalories.toInt()} kcal · '
                    '${recipe.ingredients.length} ingr.',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'AÑADIR',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.isLoading,
    required this.onSearch,
    required this.onScan,
    required this.onCreateFood,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearch;
  final VoidCallback onScan;
  final VoidCallback onCreateFood;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.4),
          width: 0.7,
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.inputBackground,
              hintText: 'Buscar alimento, ej: Nutella',
              hintStyle: TextStyle(
                color: AppColors.textMain.withOpacity(0.45),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.secondary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppColors.inputBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.search),
                    label: const Text(
                      'BUSCAR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 52,
                width: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.camera_alt, size: 22),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 52,
                width: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onCreateFood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.add, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withOpacity(0.5),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textMain,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
