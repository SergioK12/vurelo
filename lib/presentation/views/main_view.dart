import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.navigationShell
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }


  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: .5,
            color: Colors.white70
          ),
        ),
      ),
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          height: 66,
          backgroundColor: Colors.black,
          elevation: 0,
          surfaceTintColor: Colors.black,
          indicatorColor: Colors.red.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.home_rounded, color: Colors.red),
              label: "Inicio",
            ),
            NavigationDestination(
              icon: Icon(Icons.search, color: Colors.white70),
              selectedIcon: Icon(Icons.search, color: Colors.red),
              label: "Buscar"
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline, color: Colors.white70),
              selectedIcon: Icon(Icons.favorite, color: Colors.red),
              label: "Favoritos",
            ),
          ],
        ),
      ),
    );
  }
}
