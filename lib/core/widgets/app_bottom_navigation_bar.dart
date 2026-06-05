import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
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
      selectedItemColor: context.colors.primary,
      unselectedItemColor: context.colors.secondary,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 16,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: AppLocalizations.of(context)!.navigationHome,
          tooltip: AppLocalizations.of(context)!.navigationHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu_outlined),
          activeIcon: Icon(Icons.restaurant_menu),
          label: AppLocalizations.of(context)!.navigationNutrition,
          tooltip: AppLocalizations.of(context)!.navigationNutrition,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.circle_outlined),
          activeIcon: Icon(Icons.circle),
          label: AppLocalizations.of(context)!.navigationAi,
          tooltip: AppLocalizations.of(context)!.navigationAi,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center_outlined),
          activeIcon: Icon(Icons.fitness_center),
          label: AppLocalizations.of(context)!.navigationRoutines,
          tooltip: AppLocalizations.of(context)!.navigationRoutines,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: AppLocalizations.of(context)!.navigationSocial,
          tooltip: AppLocalizations.of(context)!.navigationSocial,
        ),
      ],
    );
  }
}
