import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
import '../../../../features/fitness_profile/data/models/fitness_progress_model.dart';
import '../../../../features/fitness_profile/data/models/fitness_profile_model.dart';
import '../../../../features/fitness_profile/data/services/fitness_profile_service.dart';
import '../../../../features/fitness_profile/presentation/screens/add_physical_log_screen.dart';
import '../../../../features/fitness_profile/presentation/screens/fitness_progress_screen.dart';
import 'my_recipes_screen.dart';
import 'my_foods_screen.dart';

class NutritionScreen extends StatefulWidget {
  NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final NutritionMealService _nutritionMealService = NutritionMealService();
  final WaterLogService _waterLogService = WaterLogService();
  WaterDaySummaryModel? _waterSummary;
  bool _isWaterLoading = false;
  final FitnessProfileService _fitnessProfileService = FitnessProfileService();
  final List<FitnessProgressModel> _fitnessLogs = [];
  final bool _isFitnessLoading = false;
  FitnessProfileModel? _fitnessProfile;
  bool _isLoading = false;
  String? _errorMessage;
  NutritionDaySummaryModel? _daySummary;
  late DateTime _selectedDate;
  int _summaryGeneration = 0;
  int _waterGeneration = 0;
  Timer? _debounceTimer;
  final Set<MealType> _collapsedSections = {};

  void _toggleSection(MealType type) {
    setState(() {
      if (_collapsedSections.contains(type)) {
        _collapsedSections.remove(type);
      } else {
        _collapsedSections.add(type);
      }
    });
  }

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
    _loadFitnessProfile();
    _selectDate(DateTime.now());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDaySummary() async {
    final generation = ++_summaryGeneration;
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final loadedSummary = await _nutritionMealService.getDaySummary(
        date: _selectedDate,
      );

      if (!mounted || generation != _summaryGeneration) return;

      setState(() {
        _daySummary = loadedSummary;
      });
    } on ApiException catch (error) {
      if (!mounted || generation != _summaryGeneration) return;

      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted || generation != _summaryGeneration) return;

      setState(() {
        _errorMessage = 'No se pudo cargar el resumen nutricional';
      });
    } finally {
      if (mounted && generation == _summaryGeneration) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMeal(NutritionMealModel meal) async {
    final summary = _daySummary;
    if (summary == null) return;

    final updatedMeals = List<NutritionMealModel>.from(summary.meals)
      ..removeWhere((m) => m.id == meal.id);

    final updated = NutritionDaySummaryModel(
      date: summary.date,
      totalCalories: summary.totalCalories - meal.calories,
      totalProtein: summary.totalProtein - meal.protein,
      totalCarbs: summary.totalCarbs - meal.carbs,
      totalFats: summary.totalFats - meal.fats,
      caloriesTarget: summary.caloriesTarget,
      proteinTarget: summary.proteinTarget,
      carbsTarget: summary.carbsTarget,
      fatsTarget: summary.fatsTarget,
      meals: updatedMeals,
    );

    setState(() => _daySummary = updated);

    try {
      await _nutritionMealService.deleteMeal(mealId: meal.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _daySummary = summary);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar la comida'),
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

    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      _loadDaySummary();
      _loadWaterToday();
    });
  }

  void _showAddFoodMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
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
                  color: context.colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'A�ADIR ALIMENTO A...',
              style: TextStyle(
                color: context.colors.secondary,
                fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 16),
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
    final generation = ++_waterGeneration;
    setState(() => _isWaterLoading = true);
    try {
      final summary = await _waterLogService.getTodaySummary();
      if (mounted && generation == _waterGeneration) {
        setState(() => _waterSummary = summary);
      }
    } catch (_) {
      if (mounted && generation == _waterGeneration) {
        setState(() => _waterSummary = null);
      }
    } finally {
      if (mounted && generation == _waterGeneration) {
        setState(() => _isWaterLoading = false);
      }
    }
  }

  Future<void> _setWater(double totalMl) async {
    try {
      await _waterLogService.setLog(totalMl);
      if (mounted) _loadWaterToday();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar agua'),
          ),
        );
      }
    }
  }

  Future<void> _loadFitnessProfile() async {
    try {
      final profile = await _fitnessProfileService.getMyFitnessProfile();
      if (mounted) setState(() => _fitnessProfile = profile);
    } catch (_) {}
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

    final yesterday = today.subtract(Duration(days: 1));
    final tomorrow = today.add(Duration(days: 1));

    if (target == yesterday) {
      return 'Ayer';
    }

    if (target == tomorrow) {
      return 'Ma�ana';
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
          color: context.colors.primary,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.nutritionTitle,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  _formatDayTitle(_selectedDate),
                  style: TextStyle(
                    color: context.colors.secondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                _WeekCalendar(
                  selectedDate: _selectedDate,
                  onDateSelected: _selectDate,
                ),
                SizedBox(height: 20),
                if (_isLoading)
                  const _NutritionShimmer()
                else if (_errorMessage != null)
                  _ErrorCard(
                    message: _errorMessage!,
                    onRetry: _loadDaySummary,
                  )
                else if (summary != null) ...[
                  _DailySummaryCard(
                    summary: summary,
                  ),
                  SizedBox(height: 18),
                  _MealSectionCard(
                    mealType: MealType.breakfast,
                    meals: _mealsByType(MealType.breakfast),
                    onDeleteMeal: _deleteMeal,
                    isCollapsed: _collapsedSections.contains(MealType.breakfast),
                    onToggleCollapse: () => _toggleSection(MealType.breakfast),
                    onAddFood: () => _openFoodSearch(MealType.breakfast),
                  ),
                  SizedBox(height: 14),
                  _MealSectionCard(
                    mealType: MealType.lunch,
                    meals: _mealsByType(MealType.lunch),
                    onDeleteMeal: _deleteMeal,
                    isCollapsed: _collapsedSections.contains(MealType.lunch),
                    onToggleCollapse: () => _toggleSection(MealType.lunch),
                    onAddFood: () => _openFoodSearch(MealType.lunch),
                  ),
                  SizedBox(height: 14),
                  _MealSectionCard(
                    mealType: MealType.dinner,
                    meals: _mealsByType(MealType.dinner),
                    onDeleteMeal: _deleteMeal,
                    isCollapsed: _collapsedSections.contains(MealType.dinner),
                    onToggleCollapse: () => _toggleSection(MealType.dinner),
                    onAddFood: () => _openFoodSearch(MealType.dinner),
                  ),
                  SizedBox(height: 14),
                  _MealSectionCard(
                    mealType: MealType.snack,
                    meals: _mealsByType(MealType.snack),
                    onDeleteMeal: _deleteMeal,
                    isCollapsed: _collapsedSections.contains(MealType.snack),
                    onToggleCollapse: () => _toggleSection(MealType.snack),
                    onAddFood: () => _openFoodSearch(MealType.snack),
                  ),
                  SizedBox(height: 20),
                  _WaterTrackerCard(
                    summary: _waterSummary,
                    isLoading: _isWaterLoading,
                    onSetWater: _setWater,
                  ),
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _RecipesCard(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MyRecipesScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _CreateFoodCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MyFoodsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _PhysicalTrackingCard(
                    logs: _fitnessLogs,
                    isLoading: _isFitnessLoading,
                    profile: _fitnessProfile,
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
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.add, size: 28),
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.divider.withOpacity(0.4),
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
                duration: Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? context.colors.primary
                      : context.colors.inputBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        selected ? context.colors.primary : context.colors.inputBorder,
                    width: 0.7,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _weekdayLabel(day.weekday),
                      style: TextStyle(
                        color: selected
                            ? context.colors.background
                            : context.colors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: selected
                            ? context.colors.background
                            : context.colors.textMain,
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.26),
          width: 0.8,
        ),
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
                    color: context.colors.primary,
                    backgroundColor: context.colors.inputBackground,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDouble(summary.totalCalories, ''),
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '/ ${_formatDouble(summary.caloriesTarget, 'kcal')}',
                      style: TextStyle(
                        color: context.colors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                _MacroProgressRow(
                  label: 'Prote�nas',
                  current: summary.totalProtein,
                  target: summary.proteinTarget,
                  unit: 'g',
                ),
                SizedBox(height: 12),
                _MacroProgressRow(
                  label: 'Hidratos',
                  current: summary.totalCarbs,
                  target: summary.carbsTarget,
                  unit: 'g',
                ),
                SizedBox(height: 12),
                _MacroProgressRow(
                  label: 'Grasas',
                  current: summary.totalFats,
                  target: summary.fatsTarget,
                  unit: 'g',
                ),
                SizedBox(height: 10),
                _RemainingCalories(
                  current: summary.totalCalories,
                  target: summary.caloriesTarget,
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
                style: TextStyle(
                  color: context.colors.textMain,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${_format(current)} / ${_format(target)} $unit',
              style: TextStyle(
                color: context.colors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: _progress(),
            minHeight: 8,
            color: context.colors.primary,
            backgroundColor: context.colors.inputBackground,
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
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onAddFood,
  });

  final MealType mealType;
  final List<NutritionMealModel> meals;
  final ValueChanged<NutritionMealModel> onDeleteMeal;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final VoidCallback onAddFood;

  double get totalCalories {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  double get totalProtein {
    return meals.fold(0, (sum, meal) => sum + meal.protein);
  }

  double get totalCarbs {
    return meals.fold(0, (sum, meal) => sum + meal.carbs);
  }

  double get totalFats {
    return meals.fold(0, (sum, meal) => sum + meal.fats);
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
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: context.colors.divider.withOpacity(0.38),
          width: 0.7,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleCollapse,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.colors.inputBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.colors.primary.withOpacity(0.22),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      _iconForMealType(),
                      color: context.colors.primary,
                      size: 23,
                    ),
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealType.label,
                          style: TextStyle(
                            color: context.colors.textMain,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          hasMeals
                              ? '${meals.length} alimento${meals.length == 1 ? '' : 's'}'
                              : 'Sin alimentos',
                          style: TextStyle(
                            color: context.colors.secondary,
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
                      color: context.colors.inputBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      hasMeals ? '${totalCalories.toInt()} kcal' : '-',
                      style: TextStyle(
                        color: context.colors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  AnimatedRotation(
                    turns: isCollapsed ? 0.5 : 0.0,
                    duration: Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: context.colors.secondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox.shrink(),
            secondChild: hasMeals
                ? _MealSectionBody(
                    meals: meals,
                    totalProtein: totalProtein,
                    totalCarbs: totalCarbs,
                    totalFats: totalFats,
                    onDeleteMeal: onDeleteMeal,
                  )
                : _EmptyMealSection(onAddFood: onAddFood),
            crossFadeState: isCollapsed
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _MealSectionBody extends StatelessWidget {
  const _MealSectionBody({
    required this.meals,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.onDeleteMeal,
  });

  final List<NutritionMealModel> meals;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final ValueChanged<NutritionMealModel> onDeleteMeal;

  @override
  Widget build(BuildContext context) {
    String format(double v, String u) {
      if (v % 1 == 0) return '${v.toInt()} $u';
      return '${v.toStringAsFixed(1)} $u';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        children: [
          _MealMacroSummary(
            protein: format(totalProtein, 'g'),
            carbs: format(totalCarbs, 'g'),
            fats: format(totalFats, 'g'),
          ),
          SizedBox(height: 14),
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
        ],
      ),
    );
  }
}

class _EmptyMealSection extends StatelessWidget {
  const _EmptyMealSection({required this.onAddFood});

  final VoidCallback onAddFood;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.inputBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.inputBorder, width: 0.7),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: context.colors.primary,
              size: 22,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'A�ade alimentos para calcular calor�as y macros.',
                style: TextStyle(
                  color: context.colors.textMain.withOpacity(0.55),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            TextButton(
              onPressed: onAddFood,
              style: TextButton.styleFrom(
                foregroundColor: context.colors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text('A�ADIR'),
            ),
          ],
        ),
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
            label: 'Prote�na',
            value: protein,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _MealMacroChip(
            label: 'Hidratos',
            value: carbs,
          ),
        ),
        SizedBox(width: 8),
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
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.inputBorder,
          width: 0.7,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.colors.secondary,
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
    return Dismissible(
      key: ValueKey(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.inputBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colors.inputBorder,
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
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.restaurant,
                color: context.colors.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.foodName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 7),
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
            SizedBox(width: 8),
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.colors.surface,
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
            ? context.colors.primary.withOpacity(0.14)
            : context.colors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: highlighted ? context.colors.primary : context.colors.secondary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RemainingCalories extends StatelessWidget {
  const _RemainingCalories({
    required this.current,
    required this.target,
  });

  final double current;
  final double target;

  @override
  Widget build(BuildContext context) {
    final diff = target - current;
    final remaining = diff > 0;
    final color = remaining ? context.colors.primary : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            remaining ? Icons.trending_down : Icons.trending_up,
            size: 16,
            color: color,
          ),
          SizedBox(width: 6),
          Text(
            remaining
                ? '-${diff.toInt()} kcal'
                : '+${(-diff).toInt()} kcal',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionShimmer extends StatelessWidget {
  const _NutritionShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      gradient: LinearGradient(
        colors: [
          context.colors.inputBackground,
          context.colors.divider,
          context.colors.inputBackground,
        ],
        stops: [0.3, 0.5, 0.7],
        begin: Alignment(-1, 0),
        end: Alignment(1, 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBlock(height: 158),
          SizedBox(height: 18),
          _ShimmerBlock(height: 120),
          SizedBox(height: 14),
          _ShimmerBlock(height: 120),
          SizedBox(height: 14),
          _ShimmerBlock(height: 120),
          SizedBox(height: 14),
          _ShimmerBlock(height: 120),
        ],
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(28),
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.error.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 38,
          ),
          SizedBox(height: 14),
          Text(
            message,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 18),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
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

class _WaterTrackerCard extends StatelessWidget {
  const _WaterTrackerCard({
    required this.summary,
    required this.isLoading,
    required this.onSetWater,
  });

  final WaterDaySummaryModel? summary;
  final bool isLoading;
  final Future<void> Function(double totalMl) onSetWater;

  @override
  Widget build(BuildContext context) {
    return _WaterTrackerCardBody(
      summary: summary,
      isLoading: isLoading,
      onSetWater: onSetWater,
    );
  }
}

class _WaterTrackerCardBody extends StatefulWidget {
  const _WaterTrackerCardBody({
    required this.summary,
    required this.isLoading,
    required this.onSetWater,
  });

  final WaterDaySummaryModel? summary;
  final bool isLoading;
  final Future<void> Function(double totalMl) onSetWater;

  @override
  State<_WaterTrackerCardBody> createState() => _WaterTrackerCardBodyState();
}

class _WaterTrackerCardBodyState extends State<_WaterTrackerCardBody> {
  static int _glassCount = 10;
  static double _glassMl = 200;
  double gap = 3.0;

  double get _totalMl => widget.summary?.totalMl ?? 0;

  int _getFilledGlasses(double total) => (total / _glassMl).floor();
  double _getPartialFill(double total) => (total % _glassMl) / _glassMl;

  @override
  Widget build(BuildContext context) {
    final total = _totalMl;
    final filledGlasses = _getFilledGlasses(total);
    final partialFill = _getPartialFill(total);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: context.colors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Agua',
                style: TextStyle(
                  color: context.colors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              if (widget.isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.primary,
                  ),
                )
              else
                Text(
                  '${total.toInt()} / ${_glassCount * _glassMl} ml',
                  style: TextStyle(
                    color: context.colors.textMain.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final glassWidth = (constraints.maxWidth - (_glassCount - 1) * gap) / _glassCount;
              return Row(
                children: List.generate(_glassCount, (i) {
                  final fill = i < filledGlasses
                      ? 1.0
                      : i == filledGlasses
                          ? partialFill
                          : 0.0;
                  return GestureDetector(
                    onTap: () => widget.onSetWater((i + 1) * _glassMl),
                    child: Padding(
                      padding: EdgeInsets.only(right: i == _glassCount - 1 ? 0 : gap),
                      child: _WaterGlass(
                        width: glassWidth,
                        fillLevel: fill,
                        isFilled: i < filledGlasses,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WaterGlass extends StatelessWidget {
  const _WaterGlass({
    required this.width,
    required this.fillLevel,
    required this.isFilled,
  });

  final double width;
  final double fillLevel;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 70,
      child: CustomPaint(
        painter: _WaterGlassPainter(
          fillLevel: fillLevel,
          isFilled: isFilled,
          textMainColor: context.colors.textMain,
        ),
      ),
    );
  }
}

class _WaterGlassPainter extends CustomPainter {
  _WaterGlassPainter({
    required this.fillLevel,
    required this.isFilled,
    required this.textMainColor,
  });

  final double fillLevel;
  final bool isFilled;
  final Color textMainColor;

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
        ..color = textMainColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawLine(
      Offset((w - topWidth) / 2, glassTop),
      Offset((w - topWidth) / 2 + topWidth, glassTop),
      Paint()
        ..color = textMainColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rimThickness,
    );
  }

  @override
  bool shouldRepaint(_WaterGlassPainter oldDelegate) =>
      oldDelegate.fillLevel != fillLevel || oldDelegate.isFilled != isFilled || oldDelegate.textMainColor != textMainColor;
}

class _PhysicalTrackingCard extends StatelessWidget {
  const _PhysicalTrackingCard({
    required this.logs,
    required this.isLoading,
    this.profile,
  });

  final List<FitnessProgressModel> logs;
  final bool isLoading;
  final FitnessProfileModel? profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, color: context.colors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Seguimiento F�sico',
                style: TextStyle(
                  color: context.colors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              if (isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.primary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          if (logs.isEmpty && !isLoading)
            Text(
              'A�n no hay registros',
              style: TextStyle(
                color: context.colors.textMain.withValues(alpha: 0.45),
                fontSize: 13,
              ),
            )
          else if (logs.isNotEmpty) ...[
            _FitnessBarChart(log: logs.first, profile: profile),
          ],
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddPhysicalLogScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.add, size: 18),
                  label: Text('A�adir registro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FitnessProgressScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.show_chart, size: 18),
                  label: Text('Ver resumen'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.primary,
                    side: BorderSide(
                      color: context.colors.primary.withOpacity(0.4),
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

class _FitnessBarChart extends StatelessWidget {
  const _FitnessBarChart({required this.log, this.profile});

  final FitnessProgressModel log;
  final FitnessProfileModel? profile;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (log.weight != null)
        Expanded(
          child: _MiniMetricChart(
            label: 'Peso',
            value: log.weight!,
            unit: 'kg',
            maxRef: (log.weight! * 1.5).clamp(80, 250),
            color: context.colors.primary,
          ),
        ),
      if (log.bodyFat != null)
        Expanded(
          child: _MiniMetricChart(
            label: 'Grasa',
            value: log.bodyFat!,
            unit: '%',
            maxRef: _bodyFatMaxRef(log.bodyFat!),
            color: const Color(0xFFF4A261),
          ),
        ),
      if (log.muscleMass != null)
        Expanded(
          child: _MiniMetricChart(
            label: 'M�sculo',
            value: log.muscleMass!,
            unit: 'kg',
            maxRef: (log.muscleMass! * 2.0).clamp(30, 120),
            color: const Color(0xFF2A9D8F),
          ),
        ),
    ];

    if (children.isEmpty) return SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  double _bodyFatMaxRef(double current) {
    final gender = profile?.gender;

    if (gender == 'MUJER') return current.clamp(0, 50) * 2.0;
    if (gender == 'HOMBRE') return current.clamp(0, 40) * 2.0;

    return current.clamp(0, 45) * 2.0;
  }
}

class _MiniMetricChart extends StatelessWidget {
  const _MiniMetricChart({
    required this.label,
    required this.value,
    required this.unit,
    required this.maxRef,
    required this.color,
  });

  final String label;
  final double value;
  final String unit;
  final double maxRef;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, maxRef);
    final ratio = maxRef > 0 ? clamped / maxRef : 0.0;
    final barHeight = ratio * 120;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: 32,
          height: barHeight,
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: context.colors.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CreateFoodCard extends StatelessWidget {
  const _CreateFoodCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.fastfood,
                color: Colors.black,
                size: 24,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Mis\nalimentos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipesCard extends StatelessWidget {
  const _RecipesCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.menu_book,
                color: Colors.black,
                size: 24,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Mis\nrecetas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                height: 1.3,
              ),
            ),
          ],
        ),
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
            color: context.colors.inputBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.inputBorder,
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: context.colors.primary, size: 22),
              SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: context.colors.textMain,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Icon(Icons.chevron_right, color: context.colors.secondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
