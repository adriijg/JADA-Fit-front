import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../ai/presentation/screens/ai_screen.dart';
import '../../../fitness_profile/presentation/screens/fitness_profile_screen.dart';
import '../../../nutrition/presentation/screens/nutrition_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../social/presentation/screens/social_screen.dart';
import '../../../workout/presentation/screens/routines_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppBottomNavigationItem _selectedItem = AppBottomNavigationItem.home;

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

class _HomeDashboardSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    const caloriesConsumed = 1450;
    const caloriesGoal = 2300;

    const proteinConsumed = 95;
    const proteinGoal = 160;

    const carbsConsumed = 180;
    const carbsGoal = 260;

    const fatsConsumed = 48;
    const fatsGoal = 75;

    final caloriesProgress = caloriesConsumed / caloriesGoal;

    return RefreshIndicator(
      onRefresh: () async {},
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GreetingCard(),
            const SizedBox(height: 18),
            _AiCoachCard(onTap: onOpenAi),
            const SizedBox(height: 18),
            _NutritionOverviewCard(
              caloriesConsumed: caloriesConsumed,
              caloriesGoal: caloriesGoal,
              caloriesProgress: caloriesProgress,
              proteinConsumed: proteinConsumed,
              proteinGoal: proteinGoal,
              carbsConsumed: carbsConsumed,
              carbsGoal: carbsGoal,
              fatsConsumed: fatsConsumed,
              fatsGoal: fatsGoal,
              onTap: onOpenNutrition,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _WorkoutSummaryCard(onTap: onOpenWorkout)),
                const SizedBox(width: 14),
                Expanded(
                  child: _PhysicalProgressCard(onTap: onOpenFitnessProfile),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SocialSummaryCard(onTap: onOpenSocial),
            const SizedBox(height: 18),
            _SmartQuickActionsCard(
              onScanFood: onOpenNutrition,
              onRegisterMeal: onOpenNutrition,
              onAddPhysicalData: onOpenFitnessProfile,
              onViewWorkout: onOpenWorkout,
              onAskAi: onOpenAi,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola 👋',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Este es tu panel principal. Aquí tendrás el resumen de nutrición, entrenamiento, progreso físico y recomendaciones inteligentes.',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCoachCard extends StatelessWidget {
  const _AiCoachCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.tertiary.withOpacity(0.45),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.tertiary.withOpacity(0.5),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.tertiary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coach IA',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Vas bajo de proteína. Añade una comida rica en proteína para acercarte a tu objetivo.',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}

class _NutritionOverviewCard extends StatelessWidget {
  const _NutritionOverviewCard({
    required this.caloriesConsumed,
    required this.caloriesGoal,
    required this.caloriesProgress,
    required this.proteinConsumed,
    required this.proteinGoal,
    required this.carbsConsumed,
    required this.carbsGoal,
    required this.fatsConsumed,
    required this.fatsGoal,
    required this.onTap,
  });

  final int caloriesConsumed;
  final int caloriesGoal;
  final double caloriesProgress;

  final int proteinConsumed;
  final int proteinGoal;

  final int carbsConsumed;
  final int carbsGoal;

  final int fatsConsumed;
  final int fatsGoal;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final remainingCalories = caloriesGoal - caloriesConsumed;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.22),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrición de hoy',
                        style: TextStyle(
                          color: AppColors.textMain,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Resumen de calorías y macros',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.secondary),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                _CalorieRingChart(
                  progress: caloriesProgress,
                  consumed: caloriesConsumed,
                  goal: caloriesGoal,
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NutritionMetric(
                        label: 'Consumidas',
                        value: '$caloriesConsumed kcal',
                        icon: Icons.local_fire_department,
                      ),
                      const SizedBox(height: 12),
                      _NutritionMetric(
                        label: 'Objetivo',
                        value: '$caloriesGoal kcal',
                        icon: Icons.flag_outlined,
                      ),
                      const SizedBox(height: 12),
                      _NutritionMetric(
                        label: 'Restantes',
                        value:
                            '${remainingCalories.clamp(0, caloriesGoal)} kcal',
                        icon: Icons.bolt_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _MacroProgressBar(
              label: 'Proteína',
              consumed: proteinConsumed,
              goal: proteinGoal,
              unit: 'g',
            ),
            const SizedBox(height: 14),
            _MacroProgressBar(
              label: 'Carbos',
              consumed: carbsConsumed,
              goal: carbsGoal,
              unit: 'g',
            ),
            const SizedBox(height: 14),
            _MacroProgressBar(
              label: 'Grasas',
              consumed: fatsConsumed,
              goal: fatsGoal,
              unit: 'g',
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieRingChart extends StatelessWidget {
  const _CalorieRingChart({
    required this.progress,
    required this.consumed,
    required this.goal,
  });

  final double progress;
  final int consumed;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: 116,
      height: 116,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(116, 116),
            painter: _RingProgressPainter(progress: safeProgress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(safeProgress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$consumed/$goal',
                style: TextStyle(
                  color: AppColors.textMain.withOpacity(0.68),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'kcal',
                style: TextStyle(
                  color: AppColors.textMain.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingProgressPainter extends CustomPainter {
  const _RingProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = AppColors.inputBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _NutritionMetric extends StatelessWidget {
  const _NutritionMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 19),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textMain,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  const _MacroProgressBar({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.unit,
  });

  final String label;
  final int consumed;
  final int goal;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final progress = goal == 0 ? 0.0 : (consumed / goal).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '$consumed / $goal $unit',
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.inputBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _WorkoutSummaryCard extends StatelessWidget {
  const _WorkoutSummaryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SmallDashboardCard(
      icon: Icons.fitness_center,
      title: 'Workout',
      value: 'Push Day',
      subtitle: '5 ejercicios pendientes',
      onTap: onTap,
    );
  }
}

class _PhysicalProgressCard extends StatelessWidget {
  const _PhysicalProgressCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SmallDashboardCard(
      icon: Icons.show_chart,
      title: 'Progreso',
      value: '68 kg',
      subtitle: '+8 kg desde inicio',
      onTap: onTap,
    );
  }
}

class _SmallDashboardCard extends StatelessWidget {
  const _SmallDashboardCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 158,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.4),
            width: 0.7,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const Spacer(),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textMain.withOpacity(0.62),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialSummaryCard extends StatelessWidget {
  const _SocialSummaryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.4),
            width: 0.7,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.people_outline,
                color: AppColors.primary,
                size: 27,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actividad social',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '2 retos activos · 1 solicitud pendiente',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}

class _SmartQuickActionsCard extends StatelessWidget {
  const _SmartQuickActionsCard({
    required this.onScanFood,
    required this.onRegisterMeal,
    required this.onAddPhysicalData,
    required this.onViewWorkout,
    required this.onAskAi,
  });

  final VoidCallback onScanFood;
  final VoidCallback onRegisterMeal;
  final VoidCallback onAddPhysicalData;
  final VoidCallback onViewWorkout;
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.4),
          width: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              'Accesos rápidos',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _QuickActionTile(
            icon: Icons.qr_code_scanner,
            title: 'Escanear alimento',
            subtitle: 'Lee un código de barras y busca el alimento',
            onTap: onScanFood,
          ),
          const SizedBox(height: 10),
          _QuickActionTile(
            icon: Icons.restaurant_menu,
            title: 'Registrar comida',
            subtitle: 'Añade una comida al día actual',
            onTap: onRegisterMeal,
          ),
          const SizedBox(height: 10),
          _QuickActionTile(
            icon: Icons.add_chart,
            title: 'Añadir datos físicos',
            subtitle: 'Registra peso, grasa corporal y masa muscular',
            onTap: onAddPhysicalData,
          ),
          const SizedBox(height: 10),
          _QuickActionTile(
            icon: Icons.calendar_month_outlined,
            title: 'Ver rutina',
            subtitle: 'Consulta tu entrenamiento actual',
            onTap: onViewWorkout,
          ),
          const SizedBox(height: 10),
          _QuickActionTile(
            icon: Icons.auto_awesome,
            title: 'Preguntar a la IA',
            subtitle: 'Recibe una recomendación personalizada',
            onTap: onAskAi,
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.inputBorder, width: 0.7),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}
