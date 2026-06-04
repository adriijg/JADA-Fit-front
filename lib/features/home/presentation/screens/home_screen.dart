import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../ai/presentation/providers/ai_provider.dart';
import '../../../ai/presentation/screens/ai_screen.dart';
import '../../../fitness_profile/data/models/fitness_progress_model.dart';
import '../../../fitness_profile/data/services/fitness_progress_service.dart';
import '../../../fitness_profile/presentation/screens/fitness_profile_screen.dart';
import '../../../nutrition/data/models/nutrition_day_summary_model.dart';
import '../../../nutrition/data/services/nutrition_meal_service.dart';
import '../../../nutrition/presentation/screens/nutrition_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../social/presentation/screens/social_screen.dart';
import '../../../workout/data/models/routine_model.dart';
import '../../../workout/data/services/routine_service.dart';
import '../../../workout/presentation/screens/routines_screen.dart';
import '../widgets/ai_coach_card.dart';
import '../widgets/dashboard_cards.dart';
import '../widgets/nutrition_overview_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/social_summary_card.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<_HomeDashboardSectionState> _dashboardKey = GlobalKey();
  AppBottomNavigationItem _selectedItem = AppBottomNavigationItem.home;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiProvider>().clearMessages();
    });
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen()),
    );
  }

  void _openFitnessProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FitnessProfileScreen()),
    ).then((_) {
      _dashboardKey.currentState?.refreshNutrition();
    });
  }

  void _selectNavigationItem(AppBottomNavigationItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  Widget _buildSection() {
    switch (_selectedItem) {
      case AppBottomNavigationItem.home:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _HomeDashboardSection(
            key: _dashboardKey,
            onOpenFitnessProfile: _openFitnessProfile,
            onOpenNutrition: () {
              _selectNavigationItem(AppBottomNavigationItem.nutrition);
            },
            onOpenAi: () {
              _selectNavigationItem(AppBottomNavigationItem.ai);
            },
            onOpenWorkout: () {
              _selectNavigationItem(AppBottomNavigationItem.routines);
            },
            onOpenSocial: () {
              _selectNavigationItem(AppBottomNavigationItem.social);
            },
          ),
        );

      case AppBottomNavigationItem.nutrition:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: NutritionScreen(),
        );

      case AppBottomNavigationItem.ai:
        return AiScreen();

      case AppBottomNavigationItem.routines:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: RoutinesScreen(),
        );

      case AppBottomNavigationItem.social:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SocialScreen(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72),
        child: AppHeader(onProfileTap: _openProfile),
      ),
      body: _buildSection(),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedItem: _selectedItem,
        onItemSelected: _selectNavigationItem,
      ),
    );
  }
}

class _HomeDashboardSection extends StatefulWidget {
  const _HomeDashboardSection({
    super.key,
    required this.onOpenFitnessProfile,
    required this.onOpenNutrition,
    required this.onOpenAi,
    required this.onOpenWorkout,
    required this.onOpenSocial,
  });

  final VoidCallback onOpenFitnessProfile;
  final VoidCallback onOpenNutrition;
  final VoidCallback onOpenAi;
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenSocial;

  @override
  State<_HomeDashboardSection> createState() => _HomeDashboardSectionState();
}

class _HomeDashboardSectionState extends State<_HomeDashboardSection> {
  final NutritionMealService _nutritionMealService = NutritionMealService();
  final FitnessProgressService _fitnessProgressService = FitnessProgressService();
  final RoutineService _routineService = RoutineService();

  NutritionDaySummaryModel? _daySummary;
  bool _isLoading = true;
  String? _errorMessage;

  FitnessProgressModel? _latestProgress;
  FitnessProgressModel? _firstProgress;
  List<RoutineModel> _routines = [];

  @override
  void initState() {
    super.initState();
    _loadDaySummary();
    _loadSecondaryData();
  }

  void refreshNutrition() {
    _loadDaySummary();
  }

  Future<void> _loadSecondaryData() async {
    try {
      final progress = await _fitnessProgressService.getMyFitnessProgress();
      if (mounted) {
        setState(() {
          _latestProgress = progress.isNotEmpty ? progress.last : null;
          _firstProgress = progress.isNotEmpty ? progress.first : null;
        });
      }
    } catch (_) {}
    try {
      final routines = await _routineService.getRoutines();
      if (mounted) {
        setState(() => _routines = routines);
      }
    } catch (_) {}
  }

  Future<void> _loadDaySummary() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final loadedSummary = await _nutritionMealService.getDaySummary(
        date: today,
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

  @override
  Widget build(BuildContext context) {
    final summary = _daySummary;

    final caloriesConsumed = summary?.totalCalories.toInt() ?? 0;
    final caloriesGoal = summary?.caloriesTarget.toInt() ?? 2300;

    final proteinConsumed = summary?.totalProtein.toInt() ?? 0;
    final proteinGoal = summary?.proteinTarget.toInt() ?? 160;

    final carbsConsumed = summary?.totalCarbs.toInt() ?? 0;
    final carbsGoal = summary?.carbsTarget.toInt() ?? 260;

    final fatsConsumed = summary?.totalFats.toInt() ?? 0;
    final fatsGoal = summary?.fatsTarget.toInt() ?? 75;

    final caloriesProgress = caloriesGoal == 0
        ? 0.0
        : (caloriesConsumed / caloriesGoal).clamp(0.0, 1.0);

    final currentRoutine = _routines.isNotEmpty ? _routines.first : null;
    final weightDelta = _latestProgress != null && _firstProgress != null
        ? _latestProgress!.weight! - _firstProgress!.weight!
        : null;

    return RefreshIndicator(
      onRefresh: _loadDaySummary,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AiCoachCard(onTap: widget.onOpenAi),
            SizedBox(height: 18),
            if (_isLoading)
              SizedBox(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (_errorMessage != null)
              NutritionErrorCard(
                message: _errorMessage!,
                onRetry: _loadDaySummary,
                onTap: widget.onOpenNutrition,
              )
            else
              NutritionOverviewCard(
                caloriesConsumed: caloriesConsumed,
                caloriesGoal: caloriesGoal,
                caloriesProgress: caloriesProgress,
                proteinConsumed: proteinConsumed,
                proteinGoal: proteinGoal,
                carbsConsumed: carbsConsumed,
                carbsGoal: carbsGoal,
                fatsConsumed: fatsConsumed,
                fatsGoal: fatsGoal,
                onTap: widget.onOpenNutrition,
              ),
            SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: WorkoutSummaryCard(
                    onTap: widget.onOpenWorkout,
                    workoutName: currentRoutine?.name,
                    pendingExercises: currentRoutine?.exercises.length,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: PhysicalProgressCard(
                    onTap: widget.onOpenFitnessProfile,
                    currentWeight: _latestProgress?.weight,
                    weightDelta: weightDelta,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            SocialSummaryCard(onTap: widget.onOpenSocial),
            SizedBox(height: 18),
            SmartQuickActionsCard(
              onScanFood: widget.onOpenNutrition,
              onRegisterMeal: widget.onOpenNutrition,
              onAddPhysicalData: widget.onOpenFitnessProfile,
              onViewWorkout: widget.onOpenWorkout,
              onAskAi: widget.onOpenAi,
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}