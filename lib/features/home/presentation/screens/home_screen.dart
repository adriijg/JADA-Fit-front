import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../ai/presentation/screens/ai_screen.dart';
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

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildSection() {
    switch (_selectedItem) {
      case AppBottomNavigationItem.home:
        return const _HomeScreenSection();
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
        child: AppHeader(
          onProfileTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: _buildSection(),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedItem: _selectedItem,
        onItemSelected: (item) {
          setState(() {
            _selectedItem = item;
          });
        },
      ),
    );
  }
}

class _HomeScreenSection extends StatelessWidget {
  const _HomeScreenSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.4),
            width: 0.7,
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.homeWelcomeTitle,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              AppStrings.homeWelcomeSubtitle,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
