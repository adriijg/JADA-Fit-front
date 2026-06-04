import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

enum AppBottomNavigationItem { home, nutrition, ai, routines, social }

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  final AppBottomNavigationItem selectedItem;
  final ValueChanged<AppBottomNavigationItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedItem.index,
      onTap: (index) => onItemSelected(AppBottomNavigationItem.values[index]),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondary,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 16,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: AppStrings.navigationHome,
          tooltip: AppStrings.navigationHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu_outlined),
          activeIcon: Icon(Icons.restaurant_menu),
          label: AppStrings.navigationNutrition,
          tooltip: AppStrings.navigationNutrition,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.circle_outlined),
          activeIcon: Icon(Icons.circle),
          label: AppStrings.navigationAi,
          tooltip: AppStrings.navigationAi,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center_outlined),
          activeIcon: Icon(Icons.fitness_center),
          label: AppStrings.navigationRoutines,
          tooltip: AppStrings.navigationRoutines,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: AppStrings.navigationSocial,
          tooltip: AppStrings.navigationSocial,
        ),
      ],
    );
  }
}
