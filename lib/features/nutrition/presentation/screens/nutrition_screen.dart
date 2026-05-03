import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/meal_type.dart';
import '../../data/models/nutrition_day_summary_model.dart';
import '../../data/models/nutrition_meal_model.dart';
import '../../data/services/nutrition_meal_service.dart';
import 'food_search_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final NutritionMealService _nutritionMealService = NutritionMealService();

  DateTime selectedDate = DateTime.now();

  bool isLoading = true;
  String? errorMessage;
  NutritionDaySummaryModel? daySummary;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    _loadDaySummary();
  }

  Future<void> _loadDaySummary() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedSummary = await _nutritionMealService.getDaySummary(
        date: selectedDate,
      );

      if (!mounted) return;

      setState(() {
        daySummary = loadedSummary;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'No se pudo cargar el resumen nutricional';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
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
          initialDate: selectedDate,
        ),
      ),
    );

    if (registered == true) {
      await _loadDaySummary();
    }
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
      );
    });

    _loadDaySummary();
  }

  List<NutritionMealModel> _mealsByType(MealType mealType) {
    final summary = daySummary;

    if (summary == null) return const [];

    return summary.meals.where((meal) => meal.mealType == mealType).toList();
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
    final summary = daySummary;

    return RefreshIndicator(
      onRefresh: _loadDaySummary,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: 24,
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
              _formatDayTitle(selectedDate),
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _WeekCalendar(
              selectedDate: selectedDate,
              onDateSelected: _selectDate,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const SizedBox(
                height: 420,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (errorMessage != null)
              _ErrorCard(
                message: errorMessage!,
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
                onAddFood: () => _openFoodSearch(MealType.breakfast),
                onDeleteMeal: _deleteMeal,
              ),
              const SizedBox(height: 14),
              _MealSectionCard(
                mealType: MealType.lunch,
                meals: _mealsByType(MealType.lunch),
                onAddFood: () => _openFoodSearch(MealType.lunch),
                onDeleteMeal: _deleteMeal,
              ),
              const SizedBox(height: 14),
              _MealSectionCard(
                mealType: MealType.dinner,
                meals: _mealsByType(MealType.dinner),
                onAddFood: () => _openFoodSearch(MealType.dinner),
                onDeleteMeal: _deleteMeal,
              ),
              const SizedBox(height: 14),
              _MealSectionCard(
                mealType: MealType.snack,
                meals: _mealsByType(MealType.snack),
                onAddFood: () => _openFoodSearch(MealType.snack),
                onDeleteMeal: _deleteMeal,
              ),
              const SizedBox(height: 20),
              const _AiRecipesCard(),
            ],
          ],
        ),
      ),
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
          color: AppColors.divider.withValues(alpha: 0.4),
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
          color: AppColors.primary.withValues(alpha: 0.26),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
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
    required this.onAddFood,
    required this.onDeleteMeal,
  });

  final MealType mealType;
  final List<NutritionMealModel> meals;
  final VoidCallback onAddFood;
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
          color: AppColors.divider.withValues(alpha: 0.38),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
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
                    color: AppColors.primary.withValues(alpha: 0.22),
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
                    color: AppColors.textMain.withValues(alpha: 0.45),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Añade alimentos para calcular calorías y macros.',
                      style: TextStyle(
                        color: AppColors.textMain.withValues(alpha: 0.55),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onAddFood,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(
                Icons.add,
                size: 20,
              ),
              label: const Text(
                'AÑADIR ALIMENTO',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
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
            ? AppColors.primary.withValues(alpha: 0.14)
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

class _AiRecipesCard extends StatelessWidget {
  const _AiRecipesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 25,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Recetas sugeridas por IA',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Cuando conectemos la IA con tus macros, aquí aparecerán recetas adaptadas a lo que te falta para completar el día.',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.inputBorder,
                width: 0.7,
              ),
            ),
            child: const Text(
              'Ejemplo futuro: cena alta en proteína y baja en grasas.',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
          color: AppColors.error.withValues(alpha: 0.5),
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