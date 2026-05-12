import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../ai/presentation/providers/ai_provider.dart';
import '../../../ai/presentation/screens/ai_screen.dart';
import '../../../fitness_profile/presentation/screens/fitness_profile_screen.dart';
import '../../../nutrition/data/models/nutrition_day_summary_model.dart';
import '../../../nutrition/data/services/nutrition_meal_service.dart';
import '../../../nutrition/presentation/screens/nutrition_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../social/presentation/screens/social_screen.dart';
import '../../../workout/presentation/screens/routines_screen.dart';
import '../widgets/ai_coach_card.dart';
import '../widgets/dashboard_cards.dart';
import '../widgets/greeting_card.dart';
import '../widgets/nutrition_overview_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/social_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _openFitnessProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FitnessProfileScreen()),
    );
  }

  void _selectNavigationItem(AppBottomNavigationItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  Widget _buildSection() {
    switch (_selectedItem) {
      case AppBottomNavigationItem.home:
        return _HomeDashboardSection(
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
        );

      case AppBottomNavigationItem.nutrition:
        return const NutritionScreen();

      case AppBottomNavigationItem.ai:
        return const AiScreen();

      case AppBottomNavigationItem.routines:
        return const RoutinesScreen();

      case AppBottomNavigationItem.social:
        return const SocialScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppHeader(onProfileTap: _openProfile),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: _buildSection(),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedItem: _selectedItem,
        onItemSelected: _selectNavigationItem,
      ),
    );
  }
}

class _HomeDashboardSection extends StatefulWidget {
  const _HomeDashboardSection({
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

  NutritionDaySummaryModel? _daySummary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDaySummary();
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

    return RefreshIndicator(
      onRefresh: _loadDaySummary,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GreetingCard(),
            const SizedBox(height: 18),
            AiCoachCard(onTap: widget.onOpenAi),
            const SizedBox(height: 18),
            if (_isLoading)
              const SizedBox(
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
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: WorkoutSummaryCard(onTap: widget.onOpenWorkout)),
                const SizedBox(width: 14),
                Expanded(
                  child: PhysicalProgressCard(onTap: widget.onOpenFitnessProfile),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SocialSummaryCard(onTap: widget.onOpenSocial),
            const SizedBox(height: 18),
            SmartQuickActionsCard(
              onScanFood: widget.onOpenNutrition,
              onRegisterMeal: widget.onOpenNutrition,
              onAddPhysicalData: widget.onOpenFitnessProfile,
              onViewWorkout: widget.onOpenWorkout,
              onAskAi: widget.onOpenAi,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}