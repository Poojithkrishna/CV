import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom-navigation scaffold wrapping the five primary tabs. Everything
/// else (module detail screens, forms) pushes on top of this shell so the
/// nav bar stays put while drilling into a module.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<_Destination> _destinations = [
    _Destination('/dashboard', Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
    _Destination('/finance', Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet_rounded, 'Finance'),
    _Destination('/habits', Icons.local_fire_department_outlined,
        Icons.local_fire_department_rounded, 'Habits'),
    _Destination(
        '/fitness', Icons.fitness_center_outlined, Icons.fitness_center_rounded, 'Fitness'),
    _Destination('/more', Icons.grid_view_outlined, Icons.grid_view_rounded, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final _Destination destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.path, this.icon, this.selectedIcon, this.label);

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
