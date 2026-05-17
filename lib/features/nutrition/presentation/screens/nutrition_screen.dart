import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/meal_type.dart';
import '../../data/models/nutrition_day_summary_model.dart';
import '../../data/models/nutrition_meal_model.dart';
import '../../data/services/nutrition_meal_service.dart';
import 'food_search_screen.dart';

import '../../data/models/water_log_model.dart';
import '../../data/services/water_log_service.dart';
import '../../data/models/recipe_model.dart';
import '../../data/services/recipe_service.dart';
import '../../../../features/fitness_profile/data/models/fitness_progress_model.dart';
import '../../../../features/fitness_profile/data/services/fitness_progress_service.dart';
import '../../../../features/fitness_profile/presentation/screens/add_physical_log_screen.dart';
import '../../../../features/fitness_profile/presentation/screens/fitness_progress_screen.dart';
import 'my_recipes_screen.dart';
import 'create_recipe_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final NutritionMealService _nutritionMealService = NutritionMealService();
  final WaterLogService _waterLogService = WaterLogService();
  WaterDaySummaryModel? _waterSummary;
  bool _isWaterLoading = false;
  final FitnessProgressService _fitnessProgressService = FitnessProgressService();
  List<FitnessProgressModel> _fitnessLogs = [];
  bool _isFitnessLoading = false;
  final RecipeService _recipeService = RecipeService();
  List<RecipeModel> _userRecipes = [];
  bool _isRecipesLoading = false;
  bool _isLoading = false;
  String? _errorMessage;
  NutritionDaySummaryModel? _daySummary;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    _loadDaySummary();
    _loadWaterToday();
    _loadFitnessProgress();
    _loadUserRecipes();
  }

  Future<void> _loadDaySummary() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final loadedSummary = await _nutritionMealService.getDaySummary(
        date: _selectedDate,
      );

      if (!mounted) return;

      setState(() {
        _daySummary = loadedSummary;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'No se pudo cargar el resumen nutricional';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMeal(NutritionMealModel meal) async {
    try {
      await _nutritionMealService.deleteMeal(
        mealId: meal.id,
      );

      await _loadDaySummary();
    } on ApiException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.surface,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar la comida'),
          backgroundColor: AppColors.surface,
        ),
    );
  }
}

  Future<void> _openFoodSearch(MealType mealType) async {
    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FoodSearchScreen(
          initialMealType: mealType,
          initialDate: _selectedDate,
        ),
      ),
    );

    if (registered == true) {
      await _loadDaySummary();
    }
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
      );
    });

    _loadDaySummary();
    _loadWaterToday();
  }

  void _showAddFoodMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'AÑADIR ALIMENTO A...',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _MealOptionRow(
              icon: Icons.free_breakfast,
              label: MealType.breakfast.label,
              onTap: () {
                Navigator.pop(context);
                _openFoodSearch(MealType.breakfast);
              },
            ),
            _MealOptionRow(
              icon: Icons.lunch_dining,
              label: MealType.lunch.label,
              onTap: () {
                Navigator.pop(context);
                _openFoodSearch(MealType.lunch);
              },
            ),
            _MealOptionRow(
              icon: Icons.dinner_dining,
              label: MealType.dinner.label,
              onTap: () {
                Navigator.pop(context);
                _openFoodSearch(MealType.dinner);
              },
            ),
            _MealOptionRow(
              icon: Icons.cookie_outlined,
              label: MealType.snack.label,
              onTap: () {
                Navigator.pop(context);
                _openFoodSearch(MealType.snack);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<NutritionMealModel> _mealsByType(MealType mealType) {
    final summary = _daySummary;

    if (summary == null) return const [];

    return summary.meals.where((meal) => meal.mealType == mealType).toList();
  }

  Future<void> _loadWaterToday() async {
    setState(() => _isWaterLoading = true);
    try {
      final summary = await _waterLogService.getTodaySummary();
      if (mounted) setState(() => _waterSummary = summary);
    } catch (_) {
      if (mounted) setState(() => _waterSummary = null);
    } finally {
      if (mounted) setState(() => _isWaterLoading = false);
    }
  }

  Future<void> _addWater(int ml) async {
    if (ml <= 0) return;
    try {
      await _waterLogService.addLog(ml.toDouble());
      if (mounted) _loadWaterToday();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar $ml ml de agua'),
            backgroundColor: AppColors.surface,
          ),
        );
      }
    }
  }

  Future<void> _deleteWaterLog(String logId) async {
    try {
      await _waterLogService.deleteLog(logId);
      if (mounted) _loadWaterToday();
    } catch (_) {}
  }

  Future<void> _deleteWaterAmount(int ml) async {
    if (ml <= 0) return;
    try {
      var toRemove = ml;
      final logs = List<WaterLogModel>.from(_waterSummary?.logs ?? [])
        ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
      for (final log in logs) {
        if (toRemove <= 0) break;
        await _waterLogService.deleteLog(log.id);
        toRemove -= log.amountMl.toInt();
      }
      if (mounted) _loadWaterToday();
    } catch (_) {}
  }

  Future<void> _loadFitnessProgress() async {
    setState(() => _isFitnessLoading = true);
    try {
      final logs = await _fitnessProgressService.getMyFitnessProgress();
      if (mounted) setState(() => _fitnessLogs = logs);
    } catch (_) {
      if (mounted) setState(() => _fitnessLogs = []);
    } finally {
      if (mounted) setState(() => _isFitnessLoading = false);
    }
  }

  Future<void> _loadUserRecipes() async {
    setState(() => _isRecipesLoading = true);
    try {
      final recipes = await _recipeService.getMyRecipes();
      if (mounted) setState(() => _userRecipes = recipes);
    } catch (_) {
      if (mounted) setState(() => _userRecipes = []);
    } finally {
      if (mounted) setState(() => _isRecipesLoading = false);
    }
  }

  String _formatDayTitle(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final target = DateTime(
      date.year,
      date.month,
      date.day,
    );

    if (target == today) {
      return 'Hoy';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    if (target == yesterday) {
      return 'Ayer';
    }

    if (target == tomorrow) {
      return 'Mañana';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month';
  }

  @override
  Widget build(BuildContext context) {
    final summary = _daySummary;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadDaySummary,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.nutritionTitle,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDayTitle(_selectedDate),
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                _WeekCalendar(
                  selectedDate: _selectedDate,
                  onDateSelected: _selectDate,
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const SizedBox(
                    height: 420,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (_errorMessage != null)
                  _ErrorCard(
                    message: _errorMessage!,
                    onRetry: _loadDaySummary,
                  )
                else if (summary != null) ...[
                  _DailySummaryCard(
                    summary: summary,
                  ),
                  const SizedBox(height: 18),
                  _MealSectionCard(
                    mealType: MealType.breakfast,
                    meals: _mealsByType(MealType.breakfast),
                    onDeleteMeal: _deleteMeal,
                  ),
                  const SizedBox(height: 14),
                  _MealSectionCard(
                    mealType: MealType.lunch,
                    meals: _mealsByType(MealType.lunch),
                    onDeleteMeal: _deleteMeal,
                  ),
                  const SizedBox(height: 14),
                  _MealSectionCard(
                    mealType: MealType.dinner,
                    meals: _mealsByType(MealType.dinner),
                    onDeleteMeal: _deleteMeal,
                  ),
                  const SizedBox(height: 14),
                  _MealSectionCard(
                    mealType: MealType.snack,
                    meals: _mealsByType(MealType.snack),
                    onDeleteMeal: _deleteMeal,
                  ),
                  const SizedBox(height: 20),
                  _WaterTrackerCard(
                    summary: _waterSummary,
                    isLoading: _isWaterLoading,
                    onAddWater: _addWater,
                    onDeleteWater: _deleteWaterAmount,
                    onDeleteLog: _deleteWaterLog,
                  ),
                  const SizedBox(height: 20),
                  _PhysicalTrackingCard(
                    logs: _fitnessLogs,
                    isLoading: _isFitnessLoading,
                  ),
                  const SizedBox(height: 20),
                  _RecipesCard(
                    recipes: _userRecipes,
                    isLoading: _isRecipesLoading,
                    onCreateRecipe: () async {
                      final created = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateRecipeScreen(),
                        ),
                      );
                      if (created == true) {
                        _loadUserRecipes();
                      }
                    },
                    onViewAll: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyRecipesScreen(),
                        ),
                      );
                      if (mounted) {
                        _loadUserRecipes();
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _showAddFoodMenu,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }
}

class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return normalized.subtract(
      Duration(days: normalized.weekday - 1),
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'L';
      case DateTime.tuesday:
        return 'M';
      case DateTime.wednesday:
        return 'X';
      case DateTime.thursday:
        return 'J';
      case DateTime.friday:
        return 'V';
      case DateTime.saturday:
        return 'S';
      case DateTime.sunday:
        return 'D';
      default:
        return '';
    }
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  Widget build(BuildContext context) {
    final start = _startOfWeek(selectedDate);

    final days = List.generate(
      7,
      (index) => start.add(
        Duration(days: index),
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.4),
          width: 0.7,
        ),
      ),
      child: Row(
        children: days.map((day) {
          final selected = _isSameDay(day, selectedDate);

          return Expanded(
            child: InkWell(
              onTap: () => onDateSelected(day),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        selected ? AppColors.primary : AppColors.inputBorder,
                    width: 0.7,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _weekdayLabel(day.weekday),
                      style: TextStyle(
                        color: selected
                            ? AppColors.background
                            : AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: selected
                            ? AppColors.background
                            : AppColors.textMain,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  const _DailySummaryCard({
    required this.summary,
  });

  final NutritionDaySummaryModel summary;

  double _safeProgress(double current, double target) {
    if (target <= 0) return 0;

    final progress = current / target;

    if (progress < 0) return 0;
    if (progress > 1) return 1;

    return progress;
  }

  String _formatDouble(double value, String unit) {
    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final caloriesProgress = _safeProgress(
      summary.totalCalories,
      summary.caloriesTarget,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.26),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 128,
            height: 128,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 118,
                  height: 118,
                  child: CircularProgressIndicator(
                    value: caloriesProgress,
                    strokeWidth: 12,
                    color: AppColors.primary,
                    backgroundColor: AppColors.inputBackground,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDouble(summary.totalCalories, ''),
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '/ ${_formatDouble(summary.caloriesTarget, 'kcal')}',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                _MacroProgressRow(
                  label: 'Proteínas',
                  current: summary.totalProtein,
                  target: summary.proteinTarget,
                  unit: 'g',
                ),
                const SizedBox(height: 12),
                _MacroProgressRow(
                  label: 'Hidratos',
                  current: summary.totalCarbs,
                  target: summary.carbsTarget,
                  unit: 'g',
                ),
                const SizedBox(height: 12),
                _MacroProgressRow(
                  label: 'Grasas',
                  current: summary.totalFats,
                  target: summary.fatsTarget,
                  unit: 'g',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroProgressRow extends StatelessWidget {
  const _MacroProgressRow({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
  });

  final String label;
  final double current;
  final double target;
  final String unit;

  double _progress() {
    if (target <= 0) return 0;

    final value = current / target;

    if (value < 0) return 0;
    if (value > 1) return 1;

    return value;
  }

  String _format(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${_format(current)} / ${_format(target)} $unit',
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: _progress(),
            minHeight: 8,
            color: AppColors.primary,
            backgroundColor: AppColors.inputBackground,
          ),
        ),
      ],
    );
  }
}

class _MealSectionCard extends StatelessWidget {
  const _MealSectionCard({
    required this.mealType,
    required this.meals,
    required this.onDeleteMeal,
  });

  final MealType mealType;
  final List<NutritionMealModel> meals;
  final ValueChanged<NutritionMealModel> onDeleteMeal;

  double get totalCalories {
    return meals.fold(
      0,
      (sum, meal) => sum + meal.calories,
    );
  }

  double get totalProtein {
    return meals.fold(
      0,
      (sum, meal) => sum + meal.protein,
    );
  }

  double get totalCarbs {
    return meals.fold(
      0,
      (sum, meal) => sum + meal.carbs,
    );
  }

  double get totalFats {
    return meals.fold(
      0,
      (sum, meal) => sum + meal.fats,
    );
  }

  String _formatDouble(double value, String unit) {
    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  IconData _iconForMealType() {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMeals = meals.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.38),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.22),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  _iconForMealType(),
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealType.label,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasMeals
                          ? '${meals.length} alimento${meals.length == 1 ? '' : 's'} registrado${meals.length == 1 ? '' : 's'}'
                          : 'Sin alimentos registrados',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _formatDouble(totalCalories, 'kcal'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (hasMeals) ...[
            const SizedBox(height: 16),
            _MealMacroSummary(
              protein: _formatDouble(totalProtein, 'g'),
              carbs: _formatDouble(totalCarbs, 'g'),
              fats: _formatDouble(totalFats, 'g'),
            ),
            const SizedBox(height: 14),
            Column(
              children: meals.map((meal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MealItem(
                    meal: meal,
                    onDelete: () => onDeleteMeal(meal),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.inputBorder,
                  width: 0.7,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.textMain.withOpacity(0.45),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Añade alimentos para calcular calorías y macros.',
                      style: TextStyle(
                        color: AppColors.textMain.withOpacity(0.55),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MealMacroSummary extends StatelessWidget {
  const _MealMacroSummary({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final String protein;
  final String carbs;
  final String fats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MealMacroChip(
            label: 'Proteína',
            value: protein,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MealMacroChip(
            label: 'Hidratos',
            value: carbs,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MealMacroChip(
            label: 'Grasas',
            value: fats,
          ),
        ),
      ],
    );
  }
}

class _MealMacroChip extends StatelessWidget {
  const _MealMacroChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 0.7,
        ),
      ),
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
          const SizedBox(height: 4),
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
    );
  }
}

class _MealItem extends StatelessWidget {
  const _MealItem({
    required this.meal,
    required this.onDelete,
  });

  final NutritionMealModel meal;
  final VoidCallback onDelete;

  String _formatDouble(double value, String unit) {
    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 0.7,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                Text(
                  meal.foodName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  children: [
                    _MealInfoPill(
                      value: _formatDouble(meal.quantityGrams, 'g'),
                    ),
                    _MealInfoPill(
                      value: _formatDouble(meal.calories, 'kcal'),
                      highlighted: true,
                    ),
                    _MealInfoPill(
                      value: 'P ${_formatDouble(meal.protein, 'g')}',
                    ),
                    _MealInfoPill(
                      value: 'C ${_formatDouble(meal.carbs, 'g')}',
                    ),
                    _MealInfoPill(
                      value: 'G ${_formatDouble(meal.fats, 'g')}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealInfoPill extends StatelessWidget {
  const _MealInfoPill({
    required this.value,
    this.highlighted = false,
  });

  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withOpacity(0.14)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: highlighted ? AppColors.primary : AppColors.secondary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.error.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 38,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Reintentar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterTrackerCard extends StatefulWidget {
  const _WaterTrackerCard({
    required this.summary,
    required this.isLoading,
    required this.onAddWater,
    required this.onDeleteWater,
    required this.onDeleteLog,
  });

  final WaterDaySummaryModel? summary;
  final bool isLoading;
  final Future<void> Function(int ml) onAddWater;
  final Future<void> Function(int ml) onDeleteWater;
  final Future<void> Function(String logId) onDeleteLog;

  @override
  State<_WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends State<_WaterTrackerCard> {
  static const int _glassCount = 10;
  static const double _glassMl = 200;
  int? _lastDragIndex;

  double get _totalMl => widget.summary?.totalMl ?? 0;

  int _getFilledGlasses(double total) => (total / _glassMl).floor();
  double _getPartialFill(double total) => (total % _glassMl) / _glassMl;

  void _setWaterLevel(int glassIndex) {
    final targetMl = (glassIndex + 1) * _glassMl;
    final current = _totalMl;
    final diff = targetMl - current;
    if (diff.abs() < _glassMl / 2) return;
    if (diff > 0) {
      widget.onAddWater(diff.ceil());
    } else {
      widget.onDeleteWater((-diff).ceil());
    }
  }

  int _glassIndexFromDx(double dx) {
    const step = 30.0;
    return (dx / step).floor().clamp(0, _glassCount - 1);
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalMl;
    final filledGlasses = _getFilledGlasses(total);
    final partialFill = _getPartialFill(total);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Agua',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (widget.isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                Text(
                  '${total.toInt()} / ${_glassCount * _glassMl} ml',
                  style: TextStyle(
                    color: AppColors.textMain.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRect(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                _setWaterLevel(
                  _glassIndexFromDx(details.localPosition.dx),
                );
              },
              onHorizontalDragStart: (details) {
                _lastDragIndex = _glassIndexFromDx(
                  details.localPosition.dx,
                );
                _setWaterLevel(_lastDragIndex!);
              },
              onHorizontalDragUpdate: (details) {
                final i = _glassIndexFromDx(details.localPosition.dx);
                if (i != _lastDragIndex) {
                  _lastDragIndex = i;
                  _setWaterLevel(i);
                }
              },
              onHorizontalDragEnd: (_) => _lastDragIndex = null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_glassCount, (i) {
                  final fill = i < filledGlasses
                      ? 1.0
                      : i == filledGlasses
                          ? partialFill
                          : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: _WaterGlass(
                      fillLevel: fill,
                      isFilled: i < filledGlasses,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterGlass extends StatelessWidget {
  const _WaterGlass({
    required this.fillLevel,
    required this.isFilled,
  });

  final double fillLevel;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 70,
      child: CustomPaint(
        painter: _WaterGlassPainter(
          fillLevel: fillLevel,
          isFilled: isFilled,
        ),
      ),
    );
  }
}

class _WaterGlassPainter extends CustomPainter {
  _WaterGlassPainter({
    required this.fillLevel,
    required this.isFilled,
  });

  final double fillLevel;
  final bool isFilled;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final glassTop = h * 0.06;
    final glassHeight = h * 0.72;
    final rimThickness = 2.5;
    final topWidth = w * 0.8;
    final bottomWidth = w * 0.56;

    final glassPath = Path()
      ..moveTo((w - topWidth) / 2, glassTop)
      ..lineTo((w - topWidth) / 2 + topWidth, glassTop)
      ..lineTo((w - bottomWidth) / 2 + bottomWidth, glassTop + glassHeight)
      ..lineTo((w - bottomWidth) / 2, glassTop + glassHeight)
      ..close();

    if (fillLevel > 0) {
      final waterBottom = glassTop + glassHeight;
      final waterTop = glassTop + glassHeight * (1 - fillLevel);
      final t = (waterTop - glassTop) / glassHeight;
      final waterTopWidth = topWidth + (bottomWidth - topWidth) * t;
      final waterPath = Path()
        ..moveTo((w - waterTopWidth) / 2, waterTop)
        ..lineTo((w - waterTopWidth) / 2 + waterTopWidth, waterTop)
        ..lineTo((w - bottomWidth) / 2 + bottomWidth, waterBottom)
        ..lineTo((w - bottomWidth) / 2, waterBottom)
        ..close();
      canvas.drawPath(
        waterPath,
        Paint()
          ..color = isFilled
              ? const Color(0xFF4FC3F7).withValues(alpha: 0.8)
              : const Color(0xFF4FC3F7).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawPath(
      glassPath,
      Paint()
        ..color = AppColors.textMain.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawLine(
      Offset((w - topWidth) / 2, glassTop),
      Offset((w - topWidth) / 2 + topWidth, glassTop),
      Paint()
        ..color = AppColors.textMain.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rimThickness,
    );
  }

  @override
  bool shouldRepaint(_WaterGlassPainter oldDelegate) =>
      oldDelegate.fillLevel != fillLevel || oldDelegate.isFilled != isFilled;
}

class _PhysicalTrackingCard extends StatelessWidget {
  const _PhysicalTrackingCard({
    required this.logs,
    required this.isLoading,
  });

  final List<FitnessProgressModel> logs;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Seguimiento Físico',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (logs.isEmpty && !isLoading)
            Text(
              'Aún no hay registros',
              style: TextStyle(
                color: AppColors.textMain.withValues(alpha: 0.45),
                fontSize: 13,
              ),
            )
          else ...[
            ...logs.take(3).map((log) {
              final dateStr =
                  '${log.loggedAt.day.toString().padLeft(2, '0')}/'
                  '${log.loggedAt.month.toString().padLeft(2, '0')}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: AppColors.textMain.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (log.weight != null)
                      _StatChip(label: '${log.weight!.toStringAsFixed(1)} kg'),
                    if (log.bodyFat != null)
                      _StatChip(
                          label:
                              '${log.bodyFat!.toStringAsFixed(1)}% grasa'),
                    if (log.muscleMass != null)
                      _StatChip(
                          label:
                              '${log.muscleMass!.toStringAsFixed(1)} kg músculo'),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddPhysicalLogScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Añadir registro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FitnessProgressScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.show_chart, size: 18),
                  label: const Text('Ver resumen'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textMain.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _RecipesCard extends StatelessWidget {
  const _RecipesCard({
    required this.recipes,
    required this.isLoading,
    required this.onCreateRecipe,
    required this.onViewAll,
  });

  final List<RecipeModel> recipes;
  final bool isLoading;
  final VoidCallback onCreateRecipe;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Mis Recetas',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (recipes.isEmpty && !isLoading)
            Text(
              'Aún no tienes recetas',
              style: TextStyle(
                color: AppColors.textMain.withValues(alpha: 0.45),
                fontSize: 13,
              ),
            )
          else ...[
            ...recipes.take(3).map((recipe) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        recipe.name,
                        style: TextStyle(
                          color: AppColors.textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${recipe.totalCalories.toInt()} kcal',
                      style: TextStyle(
                        color: AppColors.textMain.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCreateRecipe,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Crear receta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewAll,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Ver todas'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MealOptionRow extends StatelessWidget {
  const _MealOptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.inputBorder,
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: AppColors.secondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
